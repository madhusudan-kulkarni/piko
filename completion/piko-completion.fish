# Piko Fish Completion

# Disable file completions by default
complete -c piko -f

# Top-level commands
complete -c piko -n '__fish_use_subcommand' -a 'block' -d 'Start a blocking session'
complete -c piko -n '__fish_use_subcommand' -a 'extend' -d 'Extend the current session'
complete -c piko -n '__fish_use_subcommand' -a 'status' -d 'Show current block status'
complete -c piko -n '__fish_use_subcommand' -a 'unlock' -d 'Request early unlock'
complete -c piko -n '__fish_use_subcommand' -a 'check' -d 'Verify block consistency'
complete -c piko -n '__fish_use_subcommand' -a 'history' -d 'Show past sessions'
complete -c piko -n '__fish_use_subcommand' -a 'uninstall' -d 'Remove Piko from your system'
complete -c piko -n '__fish_use_subcommand' -a 'help' -d 'Show help'

# block subcommand
complete -c piko -n '__fish_seen_subcommand_from block' -s p -l preset -d 'Add preset blocklist' -xa '(piko block --list 2>/dev/null | awk \'{print $1}\')'
complete -c piko -n '__fish_seen_subcommand_from block' -l list -d 'List available presets'
complete -c piko -n '__fish_seen_subcommand_from block' -l force -d 'Replace existing session'
complete -c piko -n '__fish_seen_subcommand_from block' -l dry-run -d 'Show what would be blocked'
complete -c piko -n '__fish_seen_subcommand_from block' -s h -l help -d 'Show help'

# extend subcommand
complete -c piko -n '__fish_seen_subcommand_from extend' -s h -l help -d 'Show help'

# status subcommand
complete -c piko -n '__fish_seen_subcommand_from status' -s q -l quiet -d 'Exit code only'
complete -c piko -n '__fish_seen_subcommand_from status' -s h -l help -d 'Show help'

# unlock subcommand
complete -c piko -n '__fish_seen_subcommand_from unlock' -l now -d 'Emergency immediate unblock'
complete -c piko -n '__fish_seen_subcommand_from unlock' -s h -l help -d 'Show help'

# history subcommand
complete -c piko -n '__fish_seen_subcommand_from history' -s n -d 'Show last N entries'
complete -c piko -n '__fish_seen_subcommand_from history' -l week -d 'Show weekly summary'
complete -c piko -n '__fish_seen_subcommand_from history' -s h -l help -d 'Show help'

# check subcommand
complete -c piko -n '__fish_seen_subcommand_from check' -s h -l help -d 'Show help'

# uninstall subcommand
complete -c piko -n '__fish_seen_subcommand_from uninstall' -s h -l help -d 'Show help'
