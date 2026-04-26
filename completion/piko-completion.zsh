#compdef piko

_piko() {
    local -a commands
    commands=(
        'block:Start a blocking session'
        'status:Show current block status'
        'unlock:Request early unlock'
        'check:Verify block consistency'
        'uninstall:Remove Piko from your system'
        'help:Show help'
    )

    _arguments -C \
        '1:command:->command' \
        '*::arg:->args'

    case $state in
        command)
            _describe 'command' commands
            ;;
        args)
            case ${words[1]} in
                block)
                    _arguments \
                        '-p[Preset blocklist]:preset:_piko_presets' \
                        '--preset[Preset blocklist]:preset:_piko_presets' \
                        '--list[List available presets]' \
                        '--force[Replace existing session]' \
                        '-h[Show help]' \
                        '--help[Show help]' \
                        ':minutes:'
                    ;;
                unlock)
                    _arguments \
                        '--now[Emergency immediate unblock]' \
                        '-h[Show help]' \
                        '--help[Show help]' \
                        ':minutes:'
                    ;;
                status)
                    _arguments \
                        '-q[Exit 0 only if unlocked]' \
                        '--quiet[Exit 0 only if unlocked]' \
                        '-h[Show help]' \
                        '--help[Show help]'
                    ;;
                check|uninstall|help)
                    _arguments \
                        '-h[Show help]' \
                        '--help[Show help]'
                    ;;
            esac
            ;;
    esac
}

_piko_presets() {
    local -a presets
    presets=(${(f)"$(piko block --list 2>/dev/null | awk '{print $1}')"})
    _describe 'preset' presets
}

_piko "$@"