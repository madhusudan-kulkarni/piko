#!/bin/bash
set -euo pipefail

RESET_ROOT_PASSWORD=0
if [ "${1:-}" = "--reset-root-password" ]; then
    RESET_ROOT_PASSWORD=1
fi

check_deps() {
    local missing=()
    command -v python3 >/dev/null 2>&1 || missing+=("python3")
    command -v systemctl >/dev/null 2>&1 || missing+=("systemctl")
    command -v chattr >/dev/null 2>&1 || missing+=("chattr (install e2fsprogs)")
    command -v readlink >/dev/null 2>&1 || missing+=("readlink (install coreutils)")

    if [ ${#missing[@]} -gt 0 ]; then
        echo "Missing required commands: ${missing[*]}"
        echo ""
        echo "Install them with:"
        echo "  sudo apt install python3 e2fsprogs coreutils   # Debian/Ubuntu"
        echo "  sudo dnf install python3 e2fsprogs coreutils   # Fedora"
        echo "  sudo pacman -S python e2fsprogs coreutils        # Arch"
        exit 1
    fi
}

if [ "${EUID}" -ne 0 ]; then
    exec sudo "$0" "$@"
fi

check_deps

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
CURRENT_USERNAME=${SUDO_USER:-}

if [ -z "${CURRENT_USERNAME}" ]; then
    echo "Could not determine invoking user from SUDO_USER."
    echo "Run this script with sudo from the target user account."
    exit 1
fi

CURRENT_HOME=$(getent passwd "$CURRENT_USERNAME" | cut -d: -f6)
PIKO_HOME="${CURRENT_HOME}/.piko"
PIKO_BIN_DIR="${PIKO_HOME}/bin"
PIKO_STATE_DIR="${PIKO_HOME}/state"
PIKO_COMPLETIONS_DIR="${PIKO_HOME}/completions"

echo "==> Installing Piko to ${PIKO_HOME}..."

# Create directory structure
mkdir -p "$PIKO_BIN_DIR"
mkdir -p "$PIKO_STATE_DIR"
mkdir -p "$PIKO_COMPLETIONS_DIR"

# Copy core scripts
cp "$SCRIPT_DIR/piko" "$PIKO_BIN_DIR/piko"
cp "$SCRIPT_DIR/piko-lib" "$PIKO_BIN_DIR/piko-lib"
cp "$SCRIPT_DIR/piko-watchdog" "$PIKO_BIN_DIR/piko-watchdog"
cp "$SCRIPT_DIR/piko-scheduler" "$PIKO_BIN_DIR/piko-scheduler"
cp "$SCRIPT_DIR/piko-browser-guard" "$PIKO_BIN_DIR/piko-browser-guard"
cp "$SCRIPT_DIR/piko-browser-cycle" "$PIKO_BIN_DIR/piko-browser-cycle"
chmod +x "$PIKO_BIN_DIR"/piko*

# Set ownership to the real user
chown -R "${CURRENT_USERNAME}:${CURRENT_USERNAME}" "$PIKO_HOME"

# Create symlink on PATH
ln -sf "$PIKO_BIN_DIR/piko" /usr/local/bin/piko

# Create config from template if it doesn't exist
PIKO_CONFIG="${PIKO_HOME}/config"
if [ ! -f "$PIKO_CONFIG" ] && [ -f "$SCRIPT_DIR/pikorc.template" ]; then
    cp "$SCRIPT_DIR/pikorc.template" "$PIKO_CONFIG"
    chown "${CURRENT_USERNAME}:${CURRENT_USERNAME}" "$PIKO_CONFIG"
    echo "Config created at ${PIKO_CONFIG}"
    echo "Edit it to customize default duration and add custom presets"
fi

# Write version and owner files
echo "2026.04.27" > "$PIKO_STATE_DIR/version"
echo "$CURRENT_USERNAME" > "$PIKO_STATE_DIR/owner"
chown "${CURRENT_USERNAME}:${CURRENT_USERNAME}" "$PIKO_STATE_DIR/version" "$PIKO_STATE_DIR/owner"

# Install completions
if [ -d "$SCRIPT_DIR/completion" ]; then
    # Bash completion
    if [ -f "$SCRIPT_DIR/completion/piko-completion.bash" ]; then
        cp "$SCRIPT_DIR/completion/piko-completion.bash" "$PIKO_COMPLETIONS_DIR/piko-completion.bash"
        mkdir -p /etc/bash_completion.d
        install -m 644 "$SCRIPT_DIR/completion/piko-completion.bash" /etc/bash_completion.d/piko
        echo "Bash completion installed"
    fi

    # Zsh completion
    if [ -f "$SCRIPT_DIR/completion/piko-completion.zsh" ]; then
        cp "$SCRIPT_DIR/completion/piko-completion.zsh" "$PIKO_COMPLETIONS_DIR/piko-completion.zsh"
        mkdir -p "${CURRENT_HOME}/.zsh/completions"
        cp "$SCRIPT_DIR/completion/piko-completion.zsh" "${CURRENT_HOME}/.zsh/completions/_piko"
        chown -R "${CURRENT_USERNAME}:${CURRENT_USERNAME}" "${CURRENT_HOME}/.zsh" 2>/dev/null || true
        echo "Zsh completion installed"
    fi
fi

# Generate and install systemd units (substitute both PIKO_HOME and PIKO_USER)
sed -e "s|__PIKO_HOME__|${PIKO_HOME}|g" \
    -e "s|__PIKO_USER__|${CURRENT_USERNAME}|g" \
    "$SCRIPT_DIR/piko-watchdog.service.in" > /etc/systemd/system/piko-watchdog.service

sed -e "s|__PIKO_HOME__|${PIKO_HOME}|g" \
    -e "s|__PIKO_USER__|${CURRENT_USERNAME}|g" \
    "$SCRIPT_DIR/piko-scheduler.service.in" > /etc/systemd/system/piko-scheduler.service

install -m 644 "$SCRIPT_DIR/piko-watchdog.timer" /etc/systemd/system/piko-watchdog.timer
install -m 644 "$SCRIPT_DIR/piko-scheduler.timer" /etc/systemd/system/piko-scheduler.timer

systemctl daemon-reload
systemctl enable --now piko-watchdog.timer
systemctl enable --now piko-scheduler.timer

# Set up sudoers — block chattr to prevent bypass of immutable hosts file
# IMPORTANT: This only RESTRICTS chattr, it does NOT grant any new permissions.
# The user's existing sudo configuration is preserved.
EDITOR='tee' visudo -f /etc/sudoers.d/piko >/dev/null <<EOF
# Piko: prevent user from directly invoking chattr to bypass hosts file lock.
# This does NOT grant any new sudo privileges; it only adds a restriction.
# The user's existing sudo access (from /etc/sudoers or other files) is unaffected.
$CURRENT_USERNAME ALL=(ALL) !/usr/bin/chattr, !/sbin/chattr, !/usr/sbin/chattr
EOF
visudo -cf /etc/sudoers.d/piko >/dev/null

# Root password
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

# Verification
echo ""
echo "Verification"
echo "------------"
systemctl is-active piko-watchdog.timer
if sudo -l -U "$CURRENT_USERNAME" 2>/dev/null | grep -q "!/usr/bin/chattr"; then
    echo "chattr sudo policy: BLOCKED"
else
    echo "chattr sudo policy: check sudoers manually"
fi
ls -la "$PIKO_BIN_DIR/"
ls -la "$PIKO_STATE_DIR/"
ls -la /usr/local/bin/piko

echo ""
echo "Piko installed to ${PIKO_HOME}/"
echo ""
echo "  piko block 60 instagram.com youtube.com"
echo "  piko block --preset social"
echo "  piko status"
echo "  piko check"
echo "  piko unlock 30"
echo "  piko --version"