# Piko Bash Completion

_piko() {
    local cur prev commands presets
    COMPREPLY=()
    cur="${COMP_WORDS[COMP_CWORD]}"
    prev="${COMP_WORDS[COMP_CWORD-1]}"
    commands="block status unlock check uninstall help"

    if [ "$COMP_CWORD" -eq 1 ]; then
        COMPREPLY=($(compgen -W "$commands" -- "$cur"))
        return 0
    fi

    case "${COMP_WORDS[1]}" in
        block)
            # Get presets dynamically
            presets=$(piko block --list 2>/dev/null | awk '{print $1}')

            case "$prev" in
                -p|--preset)
                    COMPREPLY=($(compgen -W "$presets" -- "$cur"))
                    return 0
                    ;;
            esac

            COMPREPLY=($(compgen -W "-p --preset --list --force -h --help" -- "$cur"))

            # Suggest common durations if current word looks numeric
            if [[ "$cur" =~ ^[0-9]*$ ]] && [ -n "$cur" ]; then
                COMPREPLY+=($(compgen -W "15 30 60 90 120 180 240 480" -- "$cur"))
            fi
            ;;
        unlock)
            COMPREPLY=($(compgen -W "--now -h --help" -- "$cur"))

            if [[ "$cur" =~ ^[0-9]*$ ]] && [ -n "$cur" ]; then
                COMPREPLY+=($(compgen -W "15 30 60 90" -- "$cur"))
            fi
            ;;
        status)
            COMPREPLY=($(compgen -W "-q --quiet -h --help" -- "$cur"))
            ;;
        check|uninstall|help)
            COMPREPLY=($(compgen -W "-h --help" -- "$cur"))
            ;;
    esac

    return 0
}

complete -F _piko piko