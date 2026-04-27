#!/usr/bin/env bats

load test_helper

setup() {
    setup_piko_env
}

teardown() {
    teardown_piko_env
}

@test "fmt_duration formats seconds correctly" {
    source "$PIKO_HOME/bin/piko-lib"
    run fmt_duration 0
    [ "$output" = "0s" ]

    run fmt_duration 45
    [ "$output" = "45s" ]

    run fmt_duration 60
    [ "$output" = "1 minute" ]

    run fmt_duration 120
    [ "$output" = "2 minutes" ]

    run fmt_duration 3600
    [ "$output" = "1h" ]

    run fmt_duration 3660
    [ "$output" = "1h 1m" ]
}

@test "is_active_session returns true when unlock_at is in the future" {
    source "$PIKO_HOME/bin/piko-lib"
    set_unlock_at 300
    run is_active_session
    [ "$status" -eq 0 ]
}

@test "is_active_session returns false when unlock_at is in the past" {
    source "$PIKO_HOME/bin/piko-lib"
    set_unlock_at -10
    run is_active_session
    [ "$status" -eq 1 ]
}

@test "is_active_session returns false when unlock file is missing" {
    source "$PIKO_HOME/bin/piko-lib"
    rm -f "$PIKO_UNLOCK_FILE"
    run is_active_session
    [ "$status" -eq 1 ]
}

@test "get_preset_domains resolves correctly" {
    source "$PIKO_HOME/bin/piko-lib"
    run get_preset_domains "news"
    [[ "$output" == *"cnn.com"* ]]
    [[ "$output" == *"bbc.com"* ]]
}
