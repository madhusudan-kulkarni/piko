# Piko

Piko is a Linux website blocker for focused work sessions.

It blocks sites using:
- `/etc/hosts` rules
- Firefox/Chrome managed policies
- a systemd watchdog timer

This is a high-friction tool - sessions cannot be undone until the timer expires.

## Install

```bash
cd ~/Projects/piko
sudo ./install.sh
```

During installation, you will be prompted to set a root password. This is required for the emergency unblock feature. Choose a long, memorable passphrase.

> **Note:** Without the root password, blocks cannot be manually removed until the timer expires - this is intentional for focus.

## Quick Start

```bash
# Block sites for 60 minutes
piko-block 60 instagram.com youtube.com

# Or use presets
piko-block --preset social
piko-block -p social -p news 90
```

## Commands

```bash
piko-block <minutes> [domains...]     # Block websites
  -p, --preset NAME                   # Use preset blocklist
  -l, --list                          # List available presets
  
piko-status                           # Show current status
piko-sync                            # Verify lock/unlock consistency
piko-unlocked-now                    # Check if fully unlocked
piko-request-unlock [minutes]        # Request early unlock with cooldown
piko-request-unblock [minutes]       # Alias for piko-request-unlock
piko-unblock                         # Emergency manual unblock (requires sudo)
```

### Presets

| Preset | Domains |
|--------|---------|
| social | instagram.com, twitter.com, facebook.com, tiktok.com, reddit.com, linkedin.com |
| news | cnn.com, bbc.com, news.ycombinator.com, nytimes.com, theguardian.com |
| entertainment | youtube.com, netflix.com, twitch.tv, hulu.com, disneyplus.com |
| shopping | amazon.com, ebay.com, etsy.com |
| work | reddit.com, twitter.com, news.ycombinator.com |

## Configuration

Create `~/.pikorc` to customize defaults:

```bash
# Default duration in minutes
PIKO_DEFAULT_DURATION=60

# User-defined presets (JSON)
PIKO_PRESETS='{"custom": ["example.com", "test.com"]}'
```

## Help

All commands support `-h` or `--help`:

```bash
piko-block --help
piko-status --help
```

## Shell Completion

Bash and Zsh completion are installed automatically.

For manual sourcing:
- Bash: `source /etc/bash_completion.d/piko`
- Zsh: Add `fpath=(~/.zsh/completions $fpath)` to .zshrc

## Emergency Unblock

```bash
sudo piko-unblock
```

## Verify

```bash
make verify
```

If Piko is uninstalled, `make verify` will fail with `piko-watchdog.timer is not active` (expected).

## Uninstall

```bash
sudo ./uninstall.sh
```

## Files Installed

- Binaries: `/usr/local/bin/piko-*`
- Units: `/etc/systemd/system/piko-watchdog.service`, `/etc/systemd/system/piko-watchdog.timer`
- State: `/var/lib/piko`
- Sudo rule: `/etc/sudoers.d/piko`

## Limitations

- Piko is high-friction, not mathematically unbypassable.
- If a user keeps broad `sudo`/root powers, bypass is always possible.
- Browser policy changes are most reliable when browsers are restarted; Piko also cycles browser processes on lock/unlock.
