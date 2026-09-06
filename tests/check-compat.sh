#!/usr/bin/env bash
set -euo pipefail

root=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)

zsh -f -i -c '
  emulate -L zsh
  setopt no_unset
  root=$1
  function _compat_existing_precmd { :; }
  source "$root/shelltone.plugin.zsh"
  add-zsh-hook precmd _compat_existing_precmd
  source "$root/shelltone.plugin.zsh"
  [[ ${precmd_functions[(I)_compat_existing_precmd]} -gt 0 ]]
  [[ ${precmd_functions[(I)_shelltone_precmd]} -gt 0 ]]
  [[ -n $PROMPT ]]
' _ "$root"

bash --noprofile --norc -c '
  set -euo pipefail
  root=$1
  PROMPT_COMMAND=("compat_seen=\$?" "compat_second=\$?")
  source "$root/shelltone.bash"
  source "$root/shelltone.bash"
  set +e
  (exit 17)
  _shelltone_bash_precmd
  set -e
  [[ $compat_seen == 17 && $compat_second == 17 ]]
  [[ ${#PROMPT_COMMAND[@]} -eq 1 && ${PROMPT_COMMAND[0]} == _shelltone_bash_precmd ]]
' _ "$root"

printf '%s\n' 'compatibility checks passed'
