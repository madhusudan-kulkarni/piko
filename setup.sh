#!/bin/bash
set -e

REPO_URL="https://github.com/madhusudan-kulkarni/piko.git"
INSTALL_DIR="$HOME/.piko"

# Check dependencies
for cmd in git sudo bash; do
    command -v "$cmd" >/dev/null 2>&1 || { echo "Error: $cmd is required but not installed."; exit 1; }
done

echo "==> Installing Piko..."

if [ -d "$INSTALL_DIR/.git" ]; then
    echo "==> Updating existing Piko..."
    git -C "$INSTALL_DIR" pull || { echo "Error: failed to update. Remove $INSTALL_DIR and retry."; exit 1; }
else
    git clone "$REPO_URL" "$INSTALL_DIR" || { echo "Error: git clone failed."; exit 1; }
fi

cd "$INSTALL_DIR"
bash ./install.sh "$@"