# Piko Bash Completion

_piko_block() {
    local cur prev
    COMPREPLY=()
    cur="${COMP_WORDS[COMP_CWORD]}"
    prev="${COMP_WORDS[COMP_CWORD-1]}"
    
    local presets="social news entertainment shopping work"
    local durations="15 30 60 90 120 180 240 360 480 720 1440"
    
    case "${prev}" in
        piko-block)
            COMPREPLY=( $(compgen -W "-h --help -p --preset -l --list -d --duration" -- ${cur}) )
            return 0
            ;;
        -p|--preset)
            COMPREPLY=( $(compgen -W "${presets}" -- ${cur}) )
            return 0
            ;;
        -d|--duration)
            COMPREPLY=( $(compgen -W "${durations}" -- ${cur}) )
            return 0
            ;;
        -l|--list)
            return 0
            ;;
    esac
    
    # Default: complete numbers (for minutes) or domains
    if [[ "${cur}" =~ ^[0-9]+$ ]]; then
        COMPREPLY=( $(compgen -W "${durations}" -- ${cur}) )
    else
        COMPREPLY=()
    fi
}

_piko_status() {
    local cur
    COMPREPLY=()
    cur="${COMP_WORDS[COMP_CWORD]}"
    
    case "${prev}" in
        piko-status)
            COMPREPLY=( $(compgen -W "-h --help" -- ${cur}) )
            ;;
    esac
}

_piko_sync() {
    local cur prev
    COMPREPLY=()
    cur="${COMP_WORDS[COMP_CWORD]}"
    prev="${COMP_WORDS[COMP_CWORD-1]}"
    
    case "${prev}" in
        piko-sync)
            COMPREPLY=( $(compgen -W "-h --help" -- ${cur}) )
            ;;
    esac
}

_piko_request_unlock() {
    local cur prev
    COMPREPLY=()
    cur="${COMP_WORDS[COMP_CWORD]}"
    prev="${COMP_WORDS[COMP_CWORD-1]}"
    
    case "${prev}" in
        piko-request-unlock|piko-request-unblock)
            COMPREPLY=( $(compgen -W "-h --help" -- ${cur}) )
            ;;
        *)
            # Complete numbers for minutes
            if [[ "${cur}" =~ ^[0-9]+$ ]]; then
                COMPREPLY=( $(compgen -W "15 30 60 90 120" -- ${cur}) )
            fi
            ;;
    esac
}

_piko_unblock() {
    local cur prev
    COMPREPLY=()
    cur="${COMP_WORDS[COMP_CWORD]}"
    prev="${COMP_WORDS[COMP_CWORD-1]}"
    
    case "${prev}" in
        piko-unblock)
            COMPREPLY=( $(compgen -W "-h --help" -- ${cur}) )
            ;;
    esac
}

_piko_unlocked_now() {
    local cur prev
    COMPREPLY=()
    cur="${COMP_WORDS[COMP_CWORD]}"
    prev="${COMP_WORDS[COMP_CWORD-1]}"
    
    case "${prev}" in
        piko-unlocked-now)
            COMPREPLY=( $(compgen -W "-h --help" -- ${cur}) )
            ;;
    esac
}

complete -F _piko_block piko-block
complete -F _piko_status piko-status
complete -F _piko_sync piko-sync
complete -F _piko_request_unlock piko-request-unlock piko-request-unblock
complete -F _piko_unblock piko-unblock
complete -F _piko_unlocked_now piko-unlocked-now
