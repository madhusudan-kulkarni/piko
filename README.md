# Piko

Minimal self-blocking tool for Linux (Fedora-focused).

Piko blocks domains using:
- `/etc/hosts` entries (`# piko:` tags) + `chattr +i`
- browser managed policies (Firefox `WebsiteFilter`, Chrome/Chromium `URLBlocklist`)
- systemd watchdog (`piko-watchdog.timer`) every 60s

## Install

```bash
cd ~/Projects/piko
sudo ./install.sh
```

## Commands

```bash
piko-block 90 instagram.com youtube.com
piko-status
piko-sync
piko-unlocked-now
piko-request-unlock 30
piko-request-unblock 30
```

`piko-request-unlock` is enforced by watchdog and may take up to 60s after cooldown.

Emergency unblock:

```bash
su -
piko-unblock
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
