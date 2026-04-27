#!/bin/bash
# Test helper — sets up a sandboxed environment for piko tests.
# Sourced by every .bats file via setup().

# Create a temporary Piko home that doesn't touch the real system
setup_piko_env() {
    export PIKO_TEST_DIR
    PIKO_TEST_DIR="$(mktemp -d)"

    export PIKO_HOME="$PIKO_TEST_DIR/.piko"
    mkdir -p "$PIKO_HOME/bin" "$PIKO_HOME/state" "$PIKO_HOME/completions"

    # Point to the real source scripts (not installed ones)
    export PIKO_SRC_DIR
    PIKO_SRC_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

    # Copy piko-lib to the test bin dir so scripts can source it
    cp "$PIKO_SRC_DIR/piko-lib" "$PIKO_HOME/bin/piko-lib"

    # Create a fake hosts file (never touch /etc/hosts)
    export PIKO_TEST_HOSTS="$PIKO_TEST_DIR/hosts"
    echo "127.0.0.1 localhost" > "$PIKO_TEST_HOSTS"

    # Create a minimal config
    export PIKO_CONFIG="$PIKO_HOME/config"
    cat > "$PIKO_CONFIG" <<'EOF'
PIKO_DEFAULT_DURATION=60
PIKO_PRESETS='{
  "social": ["instagram.com", "twitter.com", "facebook.com", "tiktok.com", "reddit.com", "linkedin.com"],
  "news": ["cnn.com", "bbc.com", "news.ycombinator.com"],
  "work": ["reddit.com", "twitter.com"]
}'
EOF

    # Source piko-lib within the sandbox
    # Override paths that would touch the real system
    source "$PIKO_HOME/bin/piko-lib"
    export PIKO_HOSTS="$PIKO_TEST_HOSTS"

    # Disable colors for deterministic test output
    export NO_COLOR=1
}

teardown_piko_env() {
    if [ -n "${PIKO_TEST_DIR:-}" ] && [ -d "${PIKO_TEST_DIR:-}" ]; then
        rm -rf "$PIKO_TEST_DIR"
    fi
}

# Helper: write a fake unlock timestamp
set_unlock_at() {
    local seconds_from_now="${1:-300}"
    local unlock_at
    unlock_at=$(( $(date +%s) + seconds_from_now ))
    printf '%s\n' "$unlock_at" > "$PIKO_UNLOCK_FILE"
}

# Helper: write domains file
set_domains() {
    : > "$PIKO_DOMAINS_FILE"
    for domain in "$@"; do
        echo "$domain" >> "$PIKO_DOMAINS_FILE"
    done
}

# Helper: create a history entry
add_history_entry() {
    local json="$1"
    echo "$json" >> "$PIKO_HISTORY_FILE"
}
