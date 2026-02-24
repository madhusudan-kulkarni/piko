#!/bin/bash
set -euo pipefail

RESET_ROOT_PASSWORD=0
if [ "${1:-}" = "--reset-root-password" ]; then
    RESET_ROOT_PASSWORD=1
fi

if [ "${EUID}" -ne 0 ]; then
    exec sudo "$0" "$@"
fi

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
CURRENT_USERNAME=${SUDO_USER:-}

if [ -z "${CURRENT_USERNAME}" ]; then
    echo "Could not determine invoking user from SUDO_USER."
    echo "Run this script with sudo from the target user account."
    exit 1
fi

install -m 755 "$SCRIPT_DIR/piko-block" /usr/local/bin/piko-block
install -m 700 "$SCRIPT_DIR/piko-browser-cycle" /usr/local/bin/piko-browser-cycle
install -m 700 "$SCRIPT_DIR/piko-browser-guard" /usr/local/bin/piko-browser-guard
install -m 755 "$SCRIPT_DIR/piko-request-unlock" /usr/local/bin/piko-request-unlock
install -m 755 "$SCRIPT_DIR/piko-unblock" /usr/local/bin/piko-unblock
install -m 755 "$SCRIPT_DIR/piko-sync" /usr/local/bin/piko-sync
install -m 755 "$SCRIPT_DIR/piko-status" /usr/local/bin/piko-status
install -m 755 "$SCRIPT_DIR/piko-unlocked-now" /usr/local/bin/piko-unlocked-now
install -m 700 "$SCRIPT_DIR/piko-watchdog" /usr/local/bin/piko-watchdog

ln -sf /usr/local/bin/piko-request-unlock /usr/local/bin/piko-request-unblock
mkdir -p /var/lib/piko

install -m 644 "$SCRIPT_DIR/piko-watchdog.service" /etc/systemd/system/piko-watchdog.service
install -m 644 "$SCRIPT_DIR/piko-watchdog.timer" /etc/systemd/system/piko-watchdog.timer

systemctl daemon-reload
systemctl enable --now piko-watchdog.timer

SUDOERS_LINE="$CURRENT_USERNAME ALL=(ALL) ALL, !/usr/bin/chattr"
EDITOR='tee' visudo -f /etc/sudoers.d/piko >/dev/null <<EOF
# Allow the current user full sudo EXCEPT chattr
$SUDOERS_LINE
EOF
visudo -cf /etc/sudoers.d/piko >/dev/null

echo ""
ROOT_STATUS=$(passwd -S root 2>/dev/null | awk '{print $2}')
if [ "$RESET_ROOT_PASSWORD" -eq 1 ] || [ "$ROOT_STATUS" != "P" ]; then
    echo "Now set a root password."
    echo "Use a long, memorable passphrase (at least 6 words or 30+ characters)."
    passwd root
    echo "Write this down and store it somewhere physically inconvenient."
else
    echo "Root password already set; skipping passwd prompt."
    echo "Use --reset-root-password to force a password reset."
fi

echo ""
echo "Verification"
echo "------------"
systemctl is-active piko-watchdog.timer
if sudo -l -U "$CURRENT_USERNAME" | grep -q "!/usr/bin/chattr"; then
    echo "chattr sudo policy: BLOCKED"
else
    echo "chattr sudo policy: check sudoers manually"
fi
ls -la /usr/local/bin/piko-block /usr/local/bin/piko-browser-cycle /usr/local/bin/piko-browser-guard /usr/local/bin/piko-request-unlock /usr/local/bin/piko-unblock /usr/local/bin/piko-sync /usr/local/bin/piko-status /usr/local/bin/piko-unlocked-now /usr/local/bin/piko-watchdog
ls -la /var/lib/piko/

echo ""
echo "Piko setup complete."
echo ""
echo "  piko-block 90 instagram.com youtube.com   # block for 90 minutes"
echo "  piko-status                            # check what's blocked"
echo "  piko-sync                              # verify lock/unlock consistency"
echo "  piko-unlocked-now                      # exit 0 only when fully unlocked"
echo "  piko-request-unlock 30                 # request unlock after cooldown"
echo "  piko-request-unblock 30                # alias of piko-request-unlock"
echo "  su -                                    # switch to root"
echo "  piko-unblock                           # emergency manual unblock"
