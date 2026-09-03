# Shelltone prompt engine for Bash. Source this file from an interactive Bash session.

[[ -n ${BASH_VERSION-} ]] || return 1

SHELLTONE_ROOT=${SHELLTONE_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)}
export SHELLTONE_CONFIG=${SHELLTONE_CONFIG:-$SHELLTONE_ROOT/config/shelltone.zsh}
[[ -r $SHELLTONE_CONFIG ]] && . "$SHELLTONE_CONFIG"

: "${SHELLTONE_BAR_BG:=236}"
: "${SHELLTONE_FRAME_COLOR:=240}"
: "${SHELLTONE_SEPARATOR_FG:=244}"
: "${SHELLTONE_FADE_FG:=236}"
: "${SHELLTONE_DIR_FG:=39}"
: "${SHELLTONE_DIR_BOLD:=true}"
: "${SHELLTONE_GIT_CLEAN_FG:=81}"
: "${SHELLTONE_GIT_DIRTY_FG:=220}"
: "${SHELLTONE_GIT_AHEAD_FG:=81}"
: "${SHELLTONE_GIT_BEHIND_FG:=214}"
: "${SHELLTONE_GIT_PUSH_AHEAD_FG:=117}"
: "${SHELLTONE_GIT_PUSH_BEHIND_FG:=178}"
: "${SHELLTONE_GIT_STAGED_FG:=75}"
: "${SHELLTONE_GIT_CHANGED_FG:=215}"
: "${SHELLTONE_GIT_UNTRACKED_FG:=203}"
: "${SHELLTONE_INFO_FG:=39}"
: "${SHELLTONE_TIME_FG:=66}"
: "${SHELLTONE_STATUS_OK_FG:=70}"
: "${SHELLTONE_STATUS_ERROR_FG:=160}"
: "${SHELLTONE_TWO_LINES:=true}"
: "${SHELLTONE_SHOW_TIME:=true}"

_shelltone_bash_fg() { printf '\\[\\e[38;5;%sm\\]' "$1"; }
_shelltone_bash_bg() { printf '\\[\\e[48;5;%sm\\]' "$1"; }
_shelltone_bash_reset='\[\e[0m\]'
_shelltone_bash_bold='\[\e[1m\]'
_shelltone_bash_bold_reset='\[\e[22m\]'

_shelltone_bash_git() {
  local branch porcelain line index worktree counts upstream_ref push_ref behind=0 ahead=0 push_behind=0 push_ahead=0 staged=0 changed=0 untracked=0
  branch=$(git symbolic-ref --quiet --short HEAD 2>/dev/null) || branch="@$(git rev-parse --short HEAD 2>/dev/null)" || return 1
  porcelain=$(git status --porcelain --untracked-files=normal 2>/dev/null) || return 1
  counts=$(git rev-list --left-right --count '@{upstream}...HEAD' 2>/dev/null) || counts=''
  [[ -n $counts ]] && { behind=${counts%%[[:space:]]*}; ahead=${counts##*[[:space:]]}; }
  upstream_ref=$(git rev-parse --symbolic-full-name '@{upstream}' 2>/dev/null) || upstream_ref=''
  push_ref=$(git rev-parse --symbolic-full-name '@{push}' 2>/dev/null) || push_ref=''
  if [[ -n $push_ref && $push_ref != $upstream_ref ]]; then
    counts=$(git rev-list --left-right --count '@{push}...HEAD' 2>/dev/null) || counts=''
    [[ -n $counts ]] && { push_behind=${counts%%[[:space:]]*}; push_ahead=${counts##*[[:space:]]}; }
  fi
  while IFS= read -r line; do
    [[ -z $line ]] && continue
    if [[ ${line:0:2} == '??' ]]; then ((++untracked)); continue; fi
    index=${line:0:1}; worktree=${line:1:1}
    [[ $index != ' ' ]] && ((++staged))
    [[ $worktree != ' ' ]] && ((++changed))
  done <<< "$porcelain"
  local branch_fg=$SHELLTONE_GIT_CLEAN_FG
  (( staged || changed || untracked )) && branch_fg=$SHELLTONE_GIT_DIRTY_FG
  SHELLTONE_BASH_GIT="$(_shelltone_bash_fg "$branch_fg") ⎇  $branch"
  (( behind > 0 )) && SHELLTONE_BASH_GIT+="$(_shelltone_bash_fg "$SHELLTONE_GIT_BEHIND_FG") ⇣$behind"
  (( ahead > 0 )) && SHELLTONE_BASH_GIT+="$(_shelltone_bash_fg "$SHELLTONE_GIT_AHEAD_FG") ⇡$ahead"
  (( push_behind > 0 )) && SHELLTONE_BASH_GIT+="$(_shelltone_bash_fg "$SHELLTONE_GIT_PUSH_BEHIND_FG") ⇠$push_behind"
  (( push_ahead > 0 )) && SHELLTONE_BASH_GIT+="$(_shelltone_bash_fg "$SHELLTONE_GIT_PUSH_AHEAD_FG") ⇢$push_ahead"
  (( staged > 0 )) && SHELLTONE_BASH_GIT+="$(_shelltone_bash_fg "$SHELLTONE_GIT_STAGED_FG") +$staged"
  (( changed > 0 )) && SHELLTONE_BASH_GIT+="$(_shelltone_bash_fg "$SHELLTONE_GIT_CHANGED_FG") !$changed"
  (( untracked > 0 )) && SHELLTONE_BASH_GIT+="$(_shelltone_bash_fg "$SHELLTONE_GIT_UNTRACKED_FG") ?$untracked"
  return 0
}

_shelltone_bash_precmd() {
  local status=$? dir status_fg clock='' git=''
  [[ -n ${SHELLTONE_PREVIOUS_PROMPT_COMMAND-} ]] && eval "$SHELLTONE_PREVIOUS_PROMPT_COMMAND"
  dir=${PWD/#$HOME/~}
  _shelltone_bash_git && git=" $SHELLTONE_BASH_GIT"
  (( status == 0 )) && status_fg=$SHELLTONE_STATUS_OK_FG || status_fg=$SHELLTONE_STATUS_ERROR_FG
  [[ $SHELLTONE_SHOW_TIME == true ]] && clock=" $(_shelltone_bash_fg "$SHELLTONE_TIME_FG")$(date +"$SHELLTONE_TIME_FORMAT")"
  local dir_bold='' dir_bold_reset=''
  [[ $SHELLTONE_DIR_BOLD == true ]] && { dir_bold=${_shelltone_bash_bold}; dir_bold_reset=${_shelltone_bash_bold_reset}; }
  SHELLTONE_BASH_TOP="$(_shelltone_bash_fg "$SHELLTONE_FRAME_COLOR")╭─$(_shelltone_bash_bg "$SHELLTONE_BAR_BG")$(_shelltone_bash_fg "$SHELLTONE_DIR_FG") ${dir_bold}$dir${dir_bold_reset}$git ${_shelltone_bash_reset}$(_shelltone_bash_fg "$SHELLTONE_FADE_FG")▓▒░  ░▒▓$(_shelltone_bash_bg "$SHELLTONE_BAR_BG")$(_shelltone_bash_fg "$status_fg") $([[ $status == 0 ]] && printf '✔' || printf '✘ %s' "$status")$clock${_shelltone_bash_reset}"
}

shelltone() {
  case ${1:-help} in
    reload) . "$SHELLTONE_CONFIG" ;;
    aliases) shift; . "$SHELLTONE_ROOT/shelltone-aliases.sh"; shelltone_aliases_enable "${1:-starter}" ;;
    configure) shift; SHELLTONE_CONFIG="$SHELLTONE_CONFIG" "$SHELLTONE_ROOT/bin/shelltone-configure" "$@" && shelltone reload ;;
    themes) "$SHELLTONE_ROOT/bin/shelltone" themes ;;
    *) printf '%s\n' 'usage: shelltone {configure|reload|aliases|themes}' ;;
  esac
}

SHELLTONE_PREVIOUS_PROMPT_COMMAND=${PROMPT_COMMAND-}
PROMPT_COMMAND=_shelltone_bash_precmd
PS1='${SHELLTONE_BASH_TOP}\n\$ '
