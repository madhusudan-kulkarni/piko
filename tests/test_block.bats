#!/usr/bin/env bats

load test_helper

setup() {
    setup_piko_env
    # Mock commands that need root or system interactions
    export PATH="$PIKO_TEST_DIR/bin_mock:$PATH"
    mkdir -p "$PIKO_TEST_DIR/bin_mock"
    
    # Mock chattr
    cat > "$PIKO_TEST_DIR/bin_mock/chattr" <<'EOF'
#!/bin/bash
exit 0
EOF
    chmod +x "$PIKO_TEST_DIR/bin_mock/chattr"

    # Mock systemctl
    cat > "$PIKO_TEST_DIR/bin_mock/systemctl" <<'EOF'
#!/bin/bash
exit 0
EOF
    chmod +x "$PIKO_TEST_DIR/bin_mock/systemctl"

    # Mock piko-browser-guard
    cat > "$PIKO_HOME/bin/piko-browser-guard" <<'EOF'
#!/bin/bash
exit 0
EOF
    chmod +x "$PIKO_HOME/bin/piko-browser-guard"

    # Mock piko-browser-cycle
    cat > "$PIKO_HOME/bin/piko-browser-cycle" <<'EOF'
#!/bin/bash
exit 0
EOF
    chmod +x "$PIKO_HOME/bin/piko-browser-cycle"
    
    # We don't have sudo in the test, so we bypass ensure_root
    sed -i 's/ensure_root/#ensure_root/g' "$PIKO_SRC_DIR/piko"
}

teardown() {
    teardown_piko_env
    # Revert the ensure_root bypass
    sed -i 's/#ensure_root/ensure_root/g' "$PIKO_SRC_DIR/piko"
}

@test "piko block rejects negative duration" {
    run "$PIKO_SRC_DIR/piko" block -5 example.com
    [ "$status" -eq 1 ]
    [[ "$output" == *"duration must be a positive number"* ]]
}

@test "piko block rejects missing domains" {
    run "$PIKO_SRC_DIR/piko" block 60
    [ "$status" -eq 1 ]
    [[ "$output" == *"no sites specified"* ]]
}

@test "piko block writes to hosts file" {
    run "$PIKO_SRC_DIR/piko" block 60 example.com
    [ "$status" -eq 0 ]
    
    run grep -q "# piko:example.com:ipv4" "$PIKO_TEST_HOSTS"
    [ "$status" -eq 0 ]
    
    run grep -q "# piko:example.com:ipv6" "$PIKO_TEST_HOSTS"
    [ "$status" -eq 0 ]
}

@test "piko block resolves presets" {
    run "$PIKO_SRC_DIR/piko" block 60 --preset work
    [ "$status" -eq 0 ]
    
    run grep -q "reddit.com" "$PIKO_TEST_HOSTS"
    [ "$status" -eq 0 ]
    run grep -q "twitter.com" "$PIKO_TEST_HOSTS"
    [ "$status" -eq 0 ]
}

@test "piko block --dry-run makes no changes" {
    run "$PIKO_SRC_DIR/piko" block --dry-run 60 example.com
    [ "$status" -eq 0 ]
    
    # Should not touch hosts
    run grep -q "# piko:example.com" "$PIKO_TEST_HOSTS"
    [ "$status" -eq 1 ]
}

@test "piko status reports active session" {
    "$PIKO_SRC_DIR/piko" block 60 example.com
    run "$PIKO_SRC_DIR/piko" status
    [ "$status" -eq 0 ]
    [[ "$output" == *"Blocked for"* ]]
}

@test "piko extend adds time" {
    "$PIKO_SRC_DIR/piko" block 60 example.com
    unlock_at_before=$(cat "$PIKO_HOME/state/unlock_at")
    
    run "$PIKO_SRC_DIR/piko" extend 30
    [ "$status" -eq 0 ]
    
    unlock_at_after=$(cat "$PIKO_HOME/state/unlock_at")
    [ "$unlock_at_after" -gt "$unlock_at_before" ]
}
