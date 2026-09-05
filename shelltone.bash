# Shelltone prompt engine for Bash. Source this file from an interactive Bash session.

[[ -n ${BASH_VERSION-} ]] || return 1
if (( BASH_VERSINFO[0] < 4 || (BASH_VERSINFO[0] == 4 && BASH_VERSINFO[1] < 4) )); then
  printf "%s\\n" "Shelltone requires Bash 4.4 or newer." >&2
  return 1
fi

SHELLTONE_ROOT=${SHELLTONE_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)}
export SHELLTONE_CONFIG=${SHELLTONE_CONFIG:-$SHELLTONE_ROOT/config/shelltone.zsh}
[[ -r $SHELLTONE_CONFIG ]] && . "$SHELLTONE_CONFIG"

: "${SHELLTONE_BAR_BG:=236}"
: "${SHELLTONE_PROMPT_STYLE:=frame}"
: "${SHELLTONE_SHOW_BAR:=true}"
: "${SHELLTONE_BAR_TREATMENT:=solid}"
: "${SHELLTONE_BAR_SHADE:=dark}"
: "${SHELLTONE_BAR_SEPARATED:=true}"
: "${SHELLTONE_LEFT_DIVIDER:=>}"
: "${SHELLTONE_RIGHT_DIVIDER:=·}"
: "${SHELLTONE_LEFT_FADE:=▓▒░}"
: "${SHELLTONE_RIGHT_FADE:=░▒▓}"
: "${SHELLTONE_TOP_PREFIX:=╭─}"
: "${SHELLTONE_INPUT_PREFIX:=╰─}"
: "${SHELLTONE_PROMPT_SYMBOL:=>}"
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
: "${SHELLTONE_GIT_DIRTY_FG:=220}"
: "${SHELLTONE_GIT_DETAIL:=true}"
: "${SHELLTONE_GIT_LABEL_STYLE:=standard}"
: "${SHELLTONE_GIT_PREFIX_FG:=$SHELLTONE_GIT_CLEAN_FG}"
: "${SHELLTONE_GIT_COLON_FG:=$SHELLTONE_SEPARATOR_FG}"
: "${SHELLTONE_GIT_BRANCH_FG:=$SHELLTONE_GIT_CLEAN_FG}"
: "${SHELLTONE_INFO_FG:=39}"
: "${SHELLTONE_TIME_FG:=66}"
: "${SHELLTONE_STATUS_OK_FG:=70}"
: "${SHELLTONE_STATUS_ERROR_FG:=160}"
: "${SHELLTONE_TWO_LINES:=true}"
: "${SHELLTONE_SHOW_TIME:=true}"
: "${SHELLTONE_SHOW_STATUS:=true}"
: "${SHELLTONE_SHOW_DURATION:=true}"


. "$SHELLTONE_ROOT/shelltone-core.sh"
: "${SHELLTONE_TIME_FORMAT:=%I:%M:%S %p}"
: "${SHELLTONE_GIT_ASYNC:=true}"
: "${SHELLTONE_SHOW_GIT:=true}"
: "${SHELLTONE_PATH_MODE:=auto}"
: "${SHELLTONE_ADD_NEWLINE:=true}"
: "${SHELLTONE_SHOW_CONTEXT:=auto}"
: "${SHELLTONE_SHOW_VENV:=true}"
: "${SHELLTONE_SHOW_OS:=false}"
: "${SHELLTONE_DURATION_THRESHOLD:=3}"
: "${SHELLTONE_DURATION_FG:=248}"
: "${SHELLTONE_PROMPT_SUCCESS_FG:=76}"
: "${SHELLTONE_PROMPT_ERROR_FG:=196}"
: "${SHELLTONE_VENV_ICON:=🐍}"

_shelltone_bash_reset=$'\001\e[0m\002'
_shelltone_bash_bold=$'\001\e[1m\002'
_shelltone_bash_bold_reset=$'\001\e[22m\002'
_shelltone_bash_fg() { REPLY=$'\001\e[38;5;'"${1}m"$'\002'; }
_shelltone_bash_bg() { REPLY=$'\001\e[48;5;'"${1}m"$'\002'; }

_shelltone_bash_apply_bar_treatment() {
  [[ $SHELLTONE_SHOW_BAR == true ]] || return 0
  case ${SHELLTONE_BAR_SHADE,,} in
    soft) SHELLTONE_BAR_BG=238 ;;
    dark) SHELLTONE_BAR_BG=236 ;;
    deep) SHELLTONE_BAR_BG=234 ;;
  esac
  SHELLTONE_DIR_BG=$SHELLTONE_BAR_BG
  SHELLTONE_GIT_CLEAN_BG=$SHELLTONE_BAR_BG
  SHELLTONE_INFO_BG=$SHELLTONE_BAR_BG
  SHELLTONE_STATUS_BG=$SHELLTONE_BAR_BG
  if [[ $SHELLTONE_BAR_TREATMENT == stepped ]]; then
    SHELLTONE_GIT_CLEAN_BG=$((SHELLTONE_BAR_BG + 2))
    SHELLTONE_STATUS_BG=$((SHELLTONE_BAR_BG - 1))
  fi
}

_shelltone_git_segment() {
  _shelltone_literal "$2"
  local label=$REPLY
  _shelltone_bash_fg "$1"
  local gap=' '
  [[ ${SHELLTONE_GIT_LABEL_STYLE:-standard} != purity || ( ${_shelltone_previous_label-} != git && ${_shelltone_previous_label-} != : ) ]] || gap=''
  SHELLTONE_BASH_GIT+="$REPLY$gap$label"
  _shelltone_previous_label=$2
}

_shelltone_bash_git() {
  SHELLTONE_BASH_GIT=''
  local _shelltone_previous_label=''
  if [[ $- == *i* && $SHELLTONE_GIT_ASYNC == true ]]; then
    if [[ ${_shelltone_git_cache_dir-} != "$PWD" || $SHELLTONE_SHOW_GIT != true ]]; then
      _shelltone_git_clear
      _shelltone_git_cache_dir=$PWD
    fi
    if [[ -n ${_shelltone_git_fd-} ]] && IFS= read -r -t 0 -u "$_shelltone_git_fd"; then
      _shelltone_git_read <&"$_shelltone_git_fd" || true
      exec {_shelltone_git_fd}<&-
      unset _shelltone_git_fd
      [[ $_shelltone_git_request_dir == "$PWD" && $SHELLTONE_SHOW_GIT == true ]] || _shelltone_git_clear
    fi
    if [[ -z ${_shelltone_git_fd-} && $SHELLTONE_SHOW_GIT == true ]]; then
      _shelltone_git_request_dir=$PWD
      exec {_shelltone_git_fd}< <(_shelltone_git_collect; _shelltone_git_write)
    fi
  else
    _shelltone_git_collect
  fi
  _shelltone_git_segments
}

_shelltone_bash_right() {
  _shelltone_literal "$2"
  local label=$REPLY
  _shelltone_bash_fg "$1"
  _shelltone_right+=("$REPLY $label")
  _shelltone_right_width+=("${#label}")
}

_shelltone_bash_precmd() {
  local status=$? hook dir status_fg symbol_fg clock='' git='' duration='' context=''
  local -a _shelltone_right=() _shelltone_right_width=()
  local right='' width=0 i gap spaces=''
  # Every existing hook receives the command's status, including array hooks.
  for hook in "${_shelltone_previous_hooks[@]}"; do
    if _shelltone_bash_status "$status"; then eval "$hook"; else eval "$hook"; fi
  done
  _shelltone_bash_apply_bar_treatment
  _shelltone_path
  _shelltone_literal "$REPLY"
  dir=$REPLY
  _shelltone_bash_git && git=$SHELLTONE_BASH_GIT
  if (( status == 0 )); then status_fg=$SHELLTONE_STATUS_OK_FG; symbol_fg=$SHELLTONE_PROMPT_SUCCESS_FG
  else status_fg=$SHELLTONE_STATUS_ERROR_FG; symbol_fg=$SHELLTONE_PROMPT_ERROR_FG; fi
  if [[ $SHELLTONE_SHOW_STATUS == true ]]; then
    if (( status == 0 )); then _shelltone_bash_right "$status_fg" '✔'
    else _shelltone_bash_right "$status_fg" "✘ $status"; fi
  fi
  if [[ -n ${_shelltone_command_started-} && $SHELLTONE_SHOW_DURATION == true ]]; then
    local elapsed=$((SECONDS - _shelltone_command_started))
    if (( elapsed >= SHELLTONE_DURATION_THRESHOLD )); then
      _shelltone_duration "$elapsed"
      _shelltone_bash_right "$SHELLTONE_DURATION_FG" "$REPLY"
    fi
  fi
  unset _shelltone_command_started
  local jobs_text
  jobs_text=$(jobs -p)
  if [[ -n $jobs_text ]]; then
    local -a job_ids
    readarray -t job_ids <<< "$jobs_text"
    _shelltone_bash_right "$SHELLTONE_INFO_FG" "jobs ${#job_ids[@]}"
  fi
  if [[ $SHELLTONE_SHOW_VENV == true ]]; then
    if [[ -n ${VIRTUAL_ENV-} ]]; then
      _shelltone_bash_right "$SHELLTONE_INFO_FG" "${VIRTUAL_ENV_PROMPT:-${VIRTUAL_ENV##*/}} $SHELLTONE_VENV_ICON"
    elif [[ -n ${CONDA_DEFAULT_ENV-} && $CONDA_DEFAULT_ENV != base ]]; then
      _shelltone_bash_right "$SHELLTONE_INFO_FG" "conda $CONDA_DEFAULT_ENV"
    fi
  fi
  if [[ $SHELLTONE_SHOW_CONTEXT == always || ( $SHELLTONE_SHOW_CONTEXT == auto && ( -n ${SSH_CONNECTION-} || $EUID == 0 ) ) ]]; then
    _shelltone_bash_right "$SHELLTONE_INFO_FG" "${USER-}@${HOSTNAME%%.*}"
  fi
  if [[ $SHELLTONE_SHOW_TIME == true ]]; then
    printf -v clock "%($SHELLTONE_TIME_FORMAT)T" -1
    _shelltone_bash_right "$SHELLTONE_TIME_FG" "$clock"
  fi
  _shelltone_bash_fg "$SHELLTONE_DIR_FG"
  SHELLTONE_BASH_TOP="$REPLY $dir"
  [[ $SHELLTONE_DIR_BOLD != true ]] || SHELLTONE_BASH_TOP="$REPLY ${_shelltone_bash_bold}$dir${_shelltone_bash_bold_reset}"
  if [[ -n $git ]]; then
    if [[ $SHELLTONE_BAR_SEPARATED == true ]]; then
      _shelltone_bash_fg "$SHELLTONE_SEPARATOR_FG"
      git="$REPLY$SHELLTONE_LEFT_DIVIDER$git"
    fi
    [[ $SHELLTONE_SHOW_BAR != true ]] || { _shelltone_bash_bg "$SHELLTONE_GIT_CLEAN_BG"; git="$REPLY$git"; }
    SHELLTONE_BASH_TOP+="$git"
  fi
  local plain=$SHELLTONE_BASH_TOP
  # Strip only our generated color/weight escapes for width accounting.
  while [[ $plain == *$'\001'*$'\002'* ]]; do
    local escape=${plain#*$'\001'}
    escape=${escape%%$'\002'*}
    escape=$'\001'"$escape"$'\002'
    plain=${plain/"$escape"/}
  done
  width=${#plain}
  for ((i=0; i<${#_shelltone_right[@]}; i++)); do
    (( width + ${_shelltone_right_width[i]} + 8 < ${COLUMNS:-80} )) || break
    if (( i > 0 )) && [[ $SHELLTONE_BAR_SEPARATED == true ]]; then
      _shelltone_bash_fg "$SHELLTONE_SEPARATOR_FG"
      right+="$REPLY$SHELLTONE_RIGHT_DIVIDER"
    fi
    right+="${_shelltone_right[i]}"
    width=$((width + ${_shelltone_right_width[i]} + 2))
  done
  if [[ $SHELLTONE_SHOW_BAR == true ]]; then
    _shelltone_bash_bg "$SHELLTONE_DIR_BG"
    SHELLTONE_BASH_TOP="$REPLY$SHELLTONE_BASH_TOP"
  fi
  if [[ $SHELLTONE_TWO_LINES == true ]]; then
    _shelltone_bash_fg "$SHELLTONE_FRAME_COLOR"
    SHELLTONE_BASH_TOP="$REPLY$SHELLTONE_TOP_PREFIX$SHELLTONE_BASH_TOP"
    if [[ $SHELLTONE_SHOW_BAR == true ]]; then
      gap=$(( ${COLUMNS:-80} - width - ${#SHELLTONE_TOP_PREFIX} - ${#SHELLTONE_LEFT_FADE} - ${#SHELLTONE_RIGHT_FADE} - 3 ))
      (( gap > 0 )) || gap=1
      printf -v spaces '%*s' "$gap" ''
    fi
    _shelltone_bash_fg "$SHELLTONE_FADE_FG"
    SHELLTONE_BASH_TOP+="${_shelltone_bash_reset}$REPLY$SHELLTONE_LEFT_FADE"
    if [[ $SHELLTONE_SHOW_BAR == true && $SHELLTONE_BAR_TREATMENT == solid ]]; then
      _shelltone_bash_bg "$SHELLTONE_BAR_BG"
      SHELLTONE_BASH_TOP+="$REPLY"
    fi
    SHELLTONE_BASH_TOP+="$spaces"
    _shelltone_bash_fg "$SHELLTONE_FADE_FG"
    SHELLTONE_BASH_TOP+="$REPLY$SHELLTONE_RIGHT_FADE"
    [[ $SHELLTONE_SHOW_BAR != true ]] || { _shelltone_bash_bg "$SHELLTONE_INFO_BG"; SHELLTONE_BASH_TOP+="$REPLY"; }
    SHELLTONE_BASH_TOP+="$right${_shelltone_bash_reset}"
  else
    SHELLTONE_BASH_TOP+="$right${_shelltone_bash_reset}"
  fi
  _shelltone_bash_fg "$symbol_fg"
  SHELLTONE_BASH_INPUT="$REPLY"
  [[ $SHELLTONE_TWO_LINES != true ]] || SHELLTONE_BASH_INPUT+="$SHELLTONE_INPUT_PREFIX "
  SHELLTONE_BASH_INPUT+="$SHELLTONE_PROMPT_SYMBOL${_shelltone_bash_reset} "
  # Expand data once through these variables, so names are never shell code.
  PS1=''
  [[ $SHELLTONE_ADD_NEWLINE != true ]] || PS1='\n'
  PS1+='${SHELLTONE_BASH_TOP}'
  if [[ $SHELLTONE_TWO_LINES == true ]]; then PS1+='\n'; else PS1+=' '; fi
  PS1+='${SHELLTONE_BASH_INPUT}'
  return 0
}
_shelltone_bash_status() { return "$1"; }

shelltone() {
  case ${1:-help} in
    reload) . "$SHELLTONE_CONFIG"; _shelltone_git_clear; _shelltone_bash_precmd ;;
    aliases) shift; . "$SHELLTONE_ROOT/shelltone-aliases.sh"; shelltone_aliases_enable "${1:-starter}" ;;
    configure) shift; SHELLTONE_CONFIG="$SHELLTONE_CONFIG" "$SHELLTONE_ROOT/bin/shelltone-configure" "$@" && shelltone reload ;;
    themes|styles) "$SHELLTONE_ROOT/bin/shelltone" "$1" ;;
    install) shift; "$SHELLTONE_ROOT/bin/shelltone" install "$@" ;;
    *) printf '%s\n' 'usage: shelltone {configure|reload|aliases|themes|styles|install}' ;;
  esac
}

if [[ ${_shelltone_bash_installed:-false} != true ]]; then
  _shelltone_previous_hooks=("${PROMPT_COMMAND[@]}")
  _shelltone_bash_installed=true
  _shelltone_empty=''
  PS0="${PS0-}"'${_shelltone_empty:$((_shelltone_command_started=SECONDS)):0}'
fi
PROMPT_COMMAND=(_shelltone_bash_precmd)
