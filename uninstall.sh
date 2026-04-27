#!/bin/bash
set -euo pipefail

if [ "${EUID}" -ne 0 ]; then
    exec sudo "$0" "$@"
fi

CURRENT_USERNAME=${SUDO_USER:-}
if [ -z "$CURRENT_USERNAME" ]; then
    echo "Could not determine invoking user. Run with sudo from your user account."
    exit 1
fi

CURRENT_HOME=$(getent passwd "$CURRENT_USERNAME" | cut -d: -f6)
PIKO_HOME="${CURRENT_HOME}/.piko"
PIKO_BIN_DIR="${PIKO_HOME}/bin"

echo "This will remove Piko and all block sessions from your system."
echo ""
read -r -p "Are you sure? Type 'yes' to confirm: " confirm
[ "$confirm" != "yes" ] && echo "Aborted." && exit 0

# Remove blocks and browser policies
echo "Removing blocks..."
chattr -i /etc/hosts 2>/dev/null || true
sed -i '/# piko:/d' /etc/hosts
"$PIKO_BIN_DIR/piko-browser-guard" clear 2>/dev/null || true

# Stop watchdog service AND timer, then remove systemd units
echo "Stopping services..."
systemctl stop piko-watchdog.service piko-scheduler.service 2>/dev/null || true
systemctl disable --now piko-watchdog.timer piko-scheduler.timer 2>/dev/null || true
rm -f /etc/systemd/system/piko-watchdog.timer /etc/systemd/system/piko-scheduler.timer
rm -f /etc/systemd/system/piko-watchdog.service /etc/systemd/system/piko-scheduler.service
systemctl daemon-reload

# Remove symlink
rm -f /usr/local/bin/piko

# Remove the self-contained directory
echo "Removing piko..."
rm -rf "$PIKO_HOME"

# Remove sudoers
rm -f /etc/sudoers.d/piko

# Remove shell completions
rm -f /etc/bash_completion.d/piko
rm -f "${CURRENT_HOME}/.zsh/completions/_piko" 2>/dev/null || true

echo ""
echo "Piko uninstalled."