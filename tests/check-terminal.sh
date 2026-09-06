#!/usr/bin/env bash
set -euo pipefail

root=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
scratch=$(mktemp -d "${TMPDIR:-/tmp}/shelltone-terminal.XXXXXX")
trap 'rm -rf -- "$scratch"' EXIT
mkdir -p "$scratch/long-parent/component"
for shell in bash zsh; do
  for columns in 40 60 80; do
    if [[ $shell == bash ]]; then
      env COLUMNS="$columns" TERM=xterm-256color SHELLTONE_CONFIG=/dev/null SHELLTONE_GIT_ASYNC=false \
        bash --noprofile --norc -c 'root=$1; source "$root/shelltone.bash"; SHELLTONE_SHOW_GIT=false; SHELLTONE_SHOW_TIME=false; cd "$2"; _shelltone_bash_precmd; [[ -n $SHELLTONE_BASH_TOP && -n $SHELLTONE_BASH_INPUT ]]' _ "$root" "$scratch/long-parent/component"
    else
      env COLUMNS="$columns" TERM=xterm-256color SHELLTONE_CONFIG=/dev/null SHELLTONE_GIT_ASYNC=false \
        zsh -f -c 'root=$1; source "$root/shelltone.zsh"; SHELLTONE_SHOW_GIT=false; SHELLTONE_SHOW_TIME=false; cd "$2"; _shelltone_set_prompt; [[ -n $PROMPT ]]' _ "$root" "$scratch/long-parent/component"
    fi
  done
done

env LC_ALL=C TERM=dumb SHELLTONE_CONFIG=/dev/null zsh -f -c \
  'source "$1/shelltone.zsh"; SHELLTONE_SHOW_GIT=false; SHELLTONE_SHOW_TIME=false; cd /tmp; _shelltone_set_prompt; [[ -n $PROMPT ]]' _ "$root"

printf '%s\n' 'terminal checks passed'
