# Piko

Piko is a Linux website blocker for focused work sessions.

It blocks sites using:
- `/etc/hosts` rules
- Firefox/Chrome managed policies
- a systemd watchdog timer

This is a high-friction tool, not a guaranteed lockout if full root control is available.

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
