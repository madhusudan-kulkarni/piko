# Piko

A high-friction Linux website blocker for focused work sessions.

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

**High-friction means no shortcuts.** Once a session starts, it cannot be undone until the timer expires — the block is enforced by the OS, not your willpower.

## Install

```bash
curl -fsSL https://raw.githubusercontent.com/madhusudan-kulkarni/piko/main/setup.sh | bash
```

Or clone and install manually:

```bash
git clone https://github.com/madhusudan-kulkarni/piko.git ~/.piko
cd ~/.piko
bash ./install.sh
```

Everything installs to `~/.piko/` — binaries, config, and state. A single symlink at `/usr/local/bin/piko` puts it on your PATH.

During installation, you will be prompted to set a root password. This is required for the emergency unblock feature. Choose a long, memorable passphrase.

> **Note:** Without the root password, blocks cannot be manually removed until the timer expires — this is intentional for focus.

### Prerequisites

- Linux with **systemd**
- `sudo` access
- `bash` and `python3`
- Firefox and/or Chrome/Chromium (for browser-level policy blocking)

### Uninstall

```bash
piko uninstall
# or
make uninstall
```

Removes `~/.piko/`, the symlink, systemd units, and sudoers rules. Clean.

## How it works

Piko enforces blocks through three simultaneous layers:

1. **`/etc/hosts`** — Blocked domains are redirected to `127.0.0.1`. The hosts file is locked with `chattr +i` (immutable), preventing edits even with `sudo`.
2. **Browser policies** — Firefox, Chrome, Chromium, Brave, and Edge managed policies are deployed to block domains and disable DNS-over-HTTPS (DoH) at the browser level. This catches attempts to bypass `/etc/hosts` via alternative DNS resolvers.
3. **Watchdog timer** — A systemd timer (`piko-watchdog.timer`) runs every 60 seconds, checking whether the session has expired. When time is up, it automatically removes all blocks by reversing the three layers above. The watchdog also cycles browser processes on lock/unlock so policy changes take effect immediately.

The complete flow of a session:

```
piko block 60 twitter.com
  → writes domains to ~/.piko/state/domains
  → locks /etc/hosts with chattr +i
  → deploys browser block policies
  → kills running browsers (policy changes apply on restart)
  → sets unlock timestamp

[every 60s] watchdog checks timestamp
  → if expired: clears blocks, removes policies, restarts browsers

piko unlock 30 (optional)
  → sets a cooldown timestamp
  → watchdog clears blocks once cooldown + original timer expires
```

## Quick Start

```bash
# Block sites for 60 minutes
piko block 60 instagram.com youtube.com

# Use presets
piko block --preset social 90
piko block -p social -p news 30

# Preview what would be blocked
piko block --dry-run 60 --preset social

# List available presets
piko block --list

# Extend current session (no browser restart)
piko extend 30

# View focus history and stats
piko history --week
piko stats

# Set up automated schedules
piko schedule add --name "Morning Focus" --days "Mon,Tue,Wed,Thu,Fri" --time "09:00" --duration 120 --preset work

# Check if blocked
piko status

# Verify consistency
piko check

# View focus history
piko history --week

# Request early unlock (30-minute cooldown, cannot be cancelled)
piko unlock 30
```

Omitting a duration uses the default configured in `~/.piko/config` (default: 60 minutes).

## Commands

```
piko block <minutes> [domains...]   Start a blocking session
  -p, --preset NAME                 Add preset blocklist (repeatable)
  --list                            List available presets
  --force                           Replace existing session
  --dry-run                         Show what would be blocked

piko extend <minutes>               Extend current session (no browser restart)

piko status                         Show current block status
  -q, --quiet                       Exit code only (0=unblocked, 1=blocked)

piko stats                          Show beautiful focus statistics

piko schedule [action]              Manage automated blocking schedules
  list                              List all schedules
  add                               Add a new schedule
  remove <name>                     Remove a schedule

piko unlock [minutes]               Request early unlock (coerced cooldown)
  --now                             Emergency immediate unblock (root password)

piko history                        Show past blocking sessions
  --week                            Weekly summary with focus time stats
  -n COUNT                          Show last COUNT entries

piko check                          Verify block consistency
piko uninstall                      Remove Piko from your system
piko help                           Show help
piko --version                      Show version
```

### Coerced unlock

If you absolutely need to end a session early, use `piko unlock`:

```bash
piko unlock 30
```

This queues an early unlock after a 30-minute cooldown. Once requested, the cooldown **cannot be cancelled or shortened** — you are committed to waiting. After the cooldown expires, the watchdog clears the blocks automatically (within 60 seconds).

Use coerced unlock sparingly. The point of Piko is the friction.

### Emergency unblock

```bash
piko unlock --now
```

This requires the root password set during installation. When invoked, it removes all blocks immediately — no cooldown, no waiting. Use only for legitimate technical issues.

## Configuration

All settings are in `~/.piko/config` (created during installation). Edit it to customize defaults:

```bash
# Default duration in minutes
PIKO_DEFAULT_DURATION=60

# User-defined presets (JSON)
PIKO_PRESETS='{
  "social": ["instagram.com", "twitter.com", "facebook.com", "tiktok.com", "reddit.com", "linkedin.com"],
  "news": ["cnn.com", "bbc.com", "news.ycombinator.com", "nytimes.com", "theguardian.com"],
  "entertainment": ["youtube.com", "netflix.com", "twitch.tv", "hulu.com", "disneyplus.com"],
  "shopping": ["amazon.com", "ebay.com", "etsy.com"],
  "work": ["reddit.com", "twitter.com", "news.ycombinator.com"]
}'
```

### Presets

| Preset | Domains |
|--------|---------|
| social | instagram.com, twitter.com, facebook.com, tiktok.com, reddit.com, linkedin.com |
| news | cnn.com, bbc.com, news.ycombinator.com, nytimes.com, theguardian.com |
| entertainment | youtube.com, netflix.com, twitch.tv, hulu.com, disneyplus.com |
| shopping | amazon.com, ebay.com, etsy.com |
| work | reddit.com, twitter.com, news.ycombinator.com |

## Troubleshooting

### Blocks aren't working

Browser policy changes take effect on browser restart. Piko kills running browsers when locking/unlocking, so any newly opened browser should pick up the policies. If a browser was left running (e.g., started after the lock), restart it manually.

### Other browsers (Brave, Vivaldi, etc.)

Only Firefox and Chrome/Chromium are currently supported for policy-based blocking. `/etc/hosts` blocking still works regardless of browser — run `piko check` to verify it is active.

### Timer expired but blocks remain

The watchdog runs every 60 seconds. Wait up to a minute, then check `piko status`. If blocks persist, run `piko unlock --now` to remove them, or reboot.

### Cannot edit `/etc/hosts` manually

This is expected during an active session — Piko locks the file with `chattr +i`. The `sudoers.d/piko` rule also blocks `chattr` to prevent bypass. Use `piko unlock --now` to remove blocks cleanly.

### piko check shows drift

If `piko check` reports that your block session is active but blocking is not enforced, something went wrong. Try `piko block --force` to re-apply blocks, then `piko check` again.

## Verify

```bash
make verify
```

If Piko is uninstalled, `make verify` will fail with `piko-watchdog.timer is not active` (expected).

## Files

Everything lives in `~/.piko/`:

```
~/.piko/
├── bin/                    # piko, piko-lib, piko-browser-guard, piko-browser-cycle, piko-watchdog
├── state/                  # Runtime state (domains, unlock timers, version)
├── completions/            # Shell completions (bash, zsh)
└── config                  # User configuration (presets, defaults)
```

System paths (required for functionality):

| Path | Purpose |
|------|---------|
| `/usr/local/bin/piko` | Symlink to `~/.piko/bin/piko` (on PATH) |
| `/etc/systemd/system/piko-watchdog.service` | Watchdog service unit |
| `/etc/systemd/system/piko-watchdog.timer` | Watchdog timer (60s interval) |
| `/etc/sudoers.d/piko` | Sudo rule (blocks `chattr` for the user) |
| `/etc/hosts` | Modified during sessions (locked with `chattr +i`) |
| `/etc/firefox/policies/`, `/etc/opt/chrome/`, `/etc/chromium/` | Browser policy files |
| `/etc/brave/policies/`, `/etc/opt/edge/` | Additional browser policy files |

## Limitations

- Piko is high-friction, not mathematically unbypassable.
- If a user keeps broad `sudo`/root powers, bypass is always possible.
- Firefox, Chrome, Chromium, Brave, and Edge receive browser policy blocks (including DoH disabling). Other browsers rely solely on `/etc/hosts`.
- Browser policy changes are most reliable when browsers are restarted; Piko cycles browser processes on lock/unlock for this reason.

## License

MIT — see [LICENSE](LICENSE).
