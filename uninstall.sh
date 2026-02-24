#!/bin/bash
set -euo pipefail

if [ "${EUID}" -ne 0 ]; then
    exec sudo "$0" "$@"
fi

systemctl disable --now piko-watchdog.timer 2>/dev/null || true

rm -f /etc/systemd/system/piko-watchdog.timer
rm -f /etc/systemd/system/piko-watchdog.service
systemctl daemon-reload

rm -f /usr/local/bin/piko-block
rm -f /usr/local/bin/piko-browser-cycle
rm -f /usr/local/bin/piko-browser-guard
rm -f /usr/local/bin/piko-request-unlock
rm -f /usr/local/bin/piko-request-unblock
rm -f /usr/local/bin/piko-status
rm -f /usr/local/bin/piko-sync
rm -f /usr/local/bin/piko-unblock
rm -f /usr/local/bin/piko-unlocked-now
rm -f /usr/local/bin/piko-watchdog

rm -f /etc/sudoers.d/piko
rm -rf /var/lib/piko

echo "Piko uninstalled."
