# Piko Zsh Completion

_piko_commands=(
  'piko-block:block websites for focused work'
  'piko-status:show current blocking status'
  'piko-sync:verify consistency between state and enforcement'
  'piko-request-unlock:request early unlock with cooldown'
  'piko-unblock:emergency manual unblock'
  'piko-unlocked-now:check if fully unlocked'
)

_piko_block_opts=(
  '-h[show help]'
  '--help[show help]'
  '-p[use preset blocklist]:preset:(social news entertainment shopping work)'
  '--preset[use preset blocklist]:preset:(social news entertainment shopping work)'
  '-l[list available presets]'
  '--list[list available presets]'
  '-d[default duration]:duration:(15 30 60 90 120 180 240 360 480 720 1440)'
  '--duration[default duration]:duration:(15 30 60 90 120 180 240 360 480 720 1440)'
)

_piko_common_opts=(
  '-h[show help]'
  '--help[show help]'
)

_piko_block_args=(
  '::minutes:_numbers' 
)

_piko_request_unlock_args=(
  '::minutes:_numbers'
)

_piko() {
  local -a cmd opts args
  
  ((CURRENT == 1)) && {
    _describe 'command' _piko_commands
    return
  }
  
  local cmd="${words[1]}"
  
  case "${cmd}" in
    piko-block)
      opts=($_piko_block_opts)
      args=($_piko_block_args)
      ;;
    piko-status)
      opts=($_piko_common_opts)
      ;;
    piko-sync)
      opts=($_piko_common_opts)
      ;;
    piko-request-unlock|piko-request-unblock)
      opts=($_piko_common_opts)
      args=($_piko_request_unlock_args)
      ;;
    piko-unblock)
      opts=($_piko_common_opts)
      ;;
    piko-unlocked-now)
      opts=($_piko_common_opts)
      ;;
  esac
  
  _opts_as_args=(${=:-1})
  _arguments -s $opts $args
}

compdef _piko piko-block piko-status piko-sync piko-request-unlock piko-request-unblock piko-unblock piko-unlocked-now
