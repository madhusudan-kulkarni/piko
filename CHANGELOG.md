# Changelog

All notable changes to Piko will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).

## [Unreleased]

### Added

- **`piko stats`** — Beautiful, minimal, ANSI-colored dashboard showing all-time focus, streaks, and most-blocked sites.
- **`piko schedule`** — Automated calendar-based blocking (`add`, `list`, `remove`). Powered by a lightweight systemd timer.
- **Graceful browser restarts** — Browsers now show a desktop notification and wait 5 seconds before closing to let you save your work.
- **Test suite & CI/CD** — Comprehensive `bats` test suite and GitHub Actions workflow ensuring Piko remains unbreakable.


## [1.1.0] - 2026-04-27

### Added

- **`piko extend <minutes>`** — Extend an active session without restarting browsers. Stay in the zone.
- **`piko history`** — View past blocking sessions. Use `--week` for a weekly summary with focus time stats.
- **`--dry-run` flag for `piko block`** — Preview what would be blocked without making changes.
- **Colorized CLI output** — Bold labels, colored status indicators, and visual hierarchy. Respects `NO_COLOR` environment variable.
- **Desktop notifications** — `notify-send` alerts when sessions start, end, and are extended.
- **Structured logging** — All events logged to `~/.piko/state/piko.log` with timestamps.
- **Session history tracking** — JSONL log at `~/.piko/state/history.jsonl` powers the `piko history` command.
- **DNS-over-HTTPS blocking** — Browser policies now disable DoH in Firefox, Chrome, and Chromium, closing the #1 bypass vector.
- **Brave, Vivaldi, and Edge support** — Browser policy blocking now extends to all major Chromium-based browsers.
- **Fish shell completion** — Full tab completion for Fish shell users.

### Fixed

- **Sudoers overwrite bug** — `install.sh` previously wrote a sudoers rule granting `ALL=(ALL) ALL` which silently overrode existing user permissions. Now only restricts `chattr` without granting any new privileges.

### Changed

- Status output now shows structured, color-coded information with aligned labels.
- Block output shows a success checkmark and mentions DoH protection.
- Help output is colorized with command highlighting.
- Error messages suggest `piko extend` as an alternative to `piko block --force`.
- Updated shell completions (bash, zsh) to include all new commands and flags.

## [1.0.0] - 2026-04-26

### Added

- Three-layer blocking: `/etc/hosts`, browser policies, and watchdog timer.
- Coerced unlock with mandatory cooldown period.
- Emergency unblock with root password.
- Configurable presets (social, news, entertainment, shopping, work).
- `chattr +i` immutable lock on hosts file.
- Self-contained install to `~/.piko/`.
- Bash and Zsh shell completions.
- Systemd watchdog timer with self-healing enforcement.
- `piko block`, `piko status`, `piko unlock`, `piko check`, `piko uninstall` commands.

## [0.2.0] - 2026-04-26

### Fixed

- `load_config` was never called in `list_presets` and `get_preset_domains`.
- Correct grep pattern to detect outdated config.
- Show note if config seems outdated during install.

### Changed

- Moved all presets to config file.
- Auto-create `~/.pikorc` config during install.

## [0.1.0] - 2026-02-24

### Added

- Initial release of Piko standalone blocker.
