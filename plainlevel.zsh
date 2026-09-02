# Shelltone prompt engine. Uses ordinary terminal characters and no custom font.
# Source this file from zsh. It has no dependencies and does not require a patched font.

[[ -n ${ZSH_VERSION-} ]] || return 1

typeset -g PLAINLEVEL_ROOT=${${(%):-%N}:A:h}
typeset -g PLAINLEVEL_VERSION=0.1.0

[[ -r ${PLAINLEVEL_CONFIG:-$PLAINLEVEL_ROOT/config/plainlevel-classic.zsh} ]] &&
  source ${PLAINLEVEL_CONFIG:-$PLAINLEVEL_ROOT/config/plainlevel-classic.zsh}

# Defaults also make the theme usable with a tiny or partially written config.
: ${PLAINLEVEL_STYLE:=classic}
: ${PLAINLEVEL_COLOR_DEPTH:=256}
: ${PLAINLEVEL_TWO_LINES:=true}
: ${PLAINLEVEL_ADD_NEWLINE:=true}
: ${PLAINLEVEL_SHOW_TIME:=true}
: ${PLAINLEVEL_TIME_FORMAT:=%I:%M:%S %p}
: ${PLAINLEVEL_SHOW_CONTEXT:=auto}
: ${PLAINLEVEL_SHOW_VENV:=true}
: ${PLAINLEVEL_VENV_ICON:=🐍}
: ${PLAINLEVEL_SHOW_OS:=false}
: ${PLAINLEVEL_DURATION_THRESHOLD:=3}
: ${PLAINLEVEL_MAX_DIR_LENGTH:=38}
: ${PLAINLEVEL_FRAME_COLOR:=240}
: ${PLAINLEVEL_SEPARATOR_FG:=244}
: ${PLAINLEVEL_RIGHT_SEPARATOR:=·}
: ${PLAINLEVEL_FADE_FG:=236}
: ${PLAINLEVEL_OS_BG:=236}
: ${PLAINLEVEL_OS_FG:=255}
: ${PLAINLEVEL_DIR_BG:=236}
: ${PLAINLEVEL_DIR_FG:=39}
: ${PLAINLEVEL_DIR_BOLD:=true}
: ${PLAINLEVEL_HOME_ICON:=🏠︎}
: ${PLAINLEVEL_HOME_ICON_WIDTH:=2}
: ${PLAINLEVEL_HOME_ICON_FG:=39}
: ${PLAINLEVEL_HOME_SUB_ICON:=🗁}
: ${PLAINLEVEL_HOME_SUB_ICON_WIDTH:=2}
: ${PLAINLEVEL_HOME_SUB_ICON_FG:=39}
: ${PLAINLEVEL_FOLDER_ICON:=🗁}
: ${PLAINLEVEL_FOLDER_ICON_WIDTH:=2}
: ${PLAINLEVEL_FOLDER_ICON_FG:=39}
: ${PLAINLEVEL_DIR_ICON_GAP:='   '}
: ${PLAINLEVEL_GIT_CLEAN_BG:=236}
: ${PLAINLEVEL_GIT_CLEAN_FG:=76}
: ${PLAINLEVEL_GIT_DIRTY_BG:=236}
: ${PLAINLEVEL_GIT_DIRTY_FG:=178}
: ${PLAINLEVEL_GIT_ICON:=⎇}
: ${PLAINLEVEL_SHOW_DIR_ICONS:=false}
: ${PLAINLEVEL_SHOW_GIT_ICON:=true}
: ${PLAINLEVEL_INFO_BG:=236}
: ${PLAINLEVEL_INFO_FG:=39}
: ${PLAINLEVEL_DURATION_FG:=248}
: ${PLAINLEVEL_TIME_FG:=66}
: ${PLAINLEVEL_STATUS_BG:=236}
: ${PLAINLEVEL_STATUS_OK_FG:=70}
: ${PLAINLEVEL_STATUS_ERROR_FG:=160}

autoload -Uz add-zsh-hook
zmodload zsh/datetime 2>/dev/null || true

typeset -g _plainlevel_last_status=0
typeset -gF _plainlevel_command_started=0
typeset -gF _plainlevel_command_elapsed=0
typeset -ga _plainlevel_left_parts _plainlevel_right_parts
typeset -gr _plainlevel_fg=$'%{\e[38;5;'
typeset -gr _plainlevel_bg=$'%{\e[48;5;'
typeset -gr _plainlevel_fg_reset=$'%{\e[39m%}'
typeset -gr _plainlevel_bg_reset=$'%{\e[49m%}'
typeset -gr _plainlevel_bold=$'%{\e[1m%}'
typeset -gr _plainlevel_bold_reset=$'%{\e[22m%}'

function _plainlevel_escape_prompt() {
  REPLY=${1//\%/%%}
}

function _plainlevel_bool() {
  [[ ${1:l} == (1|true|yes|on) ]]
}

function _plainlevel_add_left() {
  _plainlevel_escape_prompt "$3"
  _plainlevel_left_parts+=("$1" "$2" "$REPLY" "${4:-false}")
}

function _plainlevel_add_right() {
  _plainlevel_escape_prompt "$3"
  _plainlevel_right_parts+=("$1" "$2" "$REPLY")
}

function _plainlevel_os_name() {
  case $OSTYPE in
    linux*)   REPLY=LINUX ;;
    darwin*)  REPLY=MAC ;;
    freebsd*) REPLY=BSD ;;
    cygwin*)  REPLY=CYGWIN ;;
    msys*)    REPLY=MSYS ;;
    *)        REPLY=UNIX ;;
  esac
}

function _plainlevel_directory() {
  local shown icon icon_width
  if [[ $PWD == $HOME ]]; then
    shown='~'
    icon=$PLAINLEVEL_HOME_ICON
    icon_width=$PLAINLEVEL_HOME_ICON_WIDTH
  elif [[ $PWD == $HOME/* ]]; then
    shown="~/${PWD#$HOME/}"
    icon=$PLAINLEVEL_HOME_SUB_ICON
    icon_width=$PLAINLEVEL_HOME_SUB_ICON_WIDTH
  else
    shown=$PWD
    icon=$PLAINLEVEL_FOLDER_ICON
    icon_width=$PLAINLEVEL_FOLDER_ICON_WIDTH
  fi
  local max=$PLAINLEVEL_MAX_DIR_LENGTH
  if (( ${#shown} > max )); then
    shown="...${shown[-$((max - 3)),-1]}"
  fi
  if _plainlevel_bool "$PLAINLEVEL_SHOW_DIR_ICONS" && [[ -n $icon ]]; then
    REPLY="${icon}${PLAINLEVEL_DIR_ICON_GAP}${shown}"
  else
    REPLY=$shown
  fi
}

function _plainlevel_git() {
  local root branch dirty ahead behind prefix=''
  root=$(command git rev-parse --show-toplevel 2>/dev/null) || return 1
  branch=$(command git symbolic-ref --quiet --short HEAD 2>/dev/null) ||
    branch="@$(command git rev-parse --short HEAD 2>/dev/null)"
  dirty=$(command git status --porcelain --untracked-files=normal 2>/dev/null)
  local counts
  counts=$(command git rev-list --left-right --count '@{upstream}...HEAD' 2>/dev/null) || counts=''
  if [[ -n $counts ]]; then
    behind=${counts%%[[:space:]]*}
    ahead=${counts##*[[:space:]]}
    (( ahead > 0 )) && branch+=" +${ahead}"
    (( behind > 0 )) && branch+=" -${behind}"
  fi
  if _plainlevel_bool "$PLAINLEVEL_SHOW_GIT_ICON" && [[ -n $PLAINLEVEL_GIT_ICON ]]; then
    prefix="${PLAINLEVEL_GIT_ICON}  "
  fi
  if [[ -n $dirty ]]; then
    REPLY="${prefix}${branch} *"
    reply=($PLAINLEVEL_GIT_DIRTY_BG $PLAINLEVEL_GIT_DIRTY_FG "$REPLY")
  else
    REPLY="${prefix}${branch}"
    reply=($PLAINLEVEL_GIT_CLEAN_BG $PLAINLEVEL_GIT_CLEAN_FG "$REPLY")
  fi
}

function _plainlevel_render_left() {
  local out='' bg fg label bold icon icon_fg rest i first=true
  for (( i = 1; i <= ${#_plainlevel_left_parts}; i += 4 )); do
    bg=${_plainlevel_left_parts[i]}
    fg=${_plainlevel_left_parts[i + 1]}
    label=${_plainlevel_left_parts[i + 2]}
    bold=${_plainlevel_left_parts[i + 3]}
    out+="${_plainlevel_bg}${bg}m%}"
    if [[ $first == false ]]; then
      out+="${_plainlevel_fg}${PLAINLEVEL_SEPARATOR_FG}m%}>"
    fi
    icon=''
    icon_fg=$fg
    case $label in
      ${PLAINLEVEL_HOME_ICON}${PLAINLEVEL_DIR_ICON_GAP}*)
        icon=$PLAINLEVEL_HOME_ICON
        icon_fg=$PLAINLEVEL_HOME_ICON_FG
        rest=${label#$icon}
        ;;
      ${PLAINLEVEL_HOME_SUB_ICON}${PLAINLEVEL_DIR_ICON_GAP}*)
        icon=$PLAINLEVEL_HOME_SUB_ICON
        icon_fg=$PLAINLEVEL_HOME_SUB_ICON_FG
        rest=${label#$icon}
        ;;
      ${PLAINLEVEL_FOLDER_ICON}${PLAINLEVEL_DIR_ICON_GAP}*)
        icon=$PLAINLEVEL_FOLDER_ICON
        icon_fg=$PLAINLEVEL_FOLDER_ICON_FG
        rest=${label#$icon}
        ;;
    esac
    out+="${_plainlevel_fg}${fg}m%} "
    _plainlevel_bool "$bold" && out+="${_plainlevel_bold}"
    if [[ -n $icon ]]; then
      out+="${_plainlevel_fg}${icon_fg}m%}${icon}${_plainlevel_fg}${fg}m%}${rest}"
    else
      out+="${label}"
    fi
    _plainlevel_bool "$bold" && out+="${_plainlevel_bold_reset}"
    out+=' '
    first=false
  done
  [[ -n $out ]] &&
    out+="${_plainlevel_bg_reset}${_plainlevel_fg}${PLAINLEVEL_FADE_FG}m%}▓▒░${_plainlevel_fg_reset}"
  REPLY=$out
}

function _plainlevel_render_right() {
  local out="${_plainlevel_fg}${PLAINLEVEL_FADE_FG}m%}░▒▓${_plainlevel_fg_reset}" bg fg label i first=true
  for (( i = 1; i <= ${#_plainlevel_right_parts}; i += 3 )); do
    bg=${_plainlevel_right_parts[i]}
    fg=${_plainlevel_right_parts[i + 1]}
    label=${_plainlevel_right_parts[i + 2]}
    out+="${_plainlevel_bg}${bg}m%}"
    if [[ $first == false ]]; then
      out+="${_plainlevel_fg}${PLAINLEVEL_SEPARATOR_FG}m%}${PLAINLEVEL_RIGHT_SEPARATOR}"
    fi
    out+="${_plainlevel_fg}${fg}m%} ${label} "
    first=false
  done
  [[ -n $out ]] && out+="${_plainlevel_bg_reset}${_plainlevel_fg_reset}"
  REPLY=$out
}

function _plainlevel_parts_width() {
  local -a parts=("${(@P)1}")
  local width=0 i count=0
  for (( i = 3; i <= ${#parts}; i += 3 )); do
    (( width += ${#parts[i]} + 2 ))
    (( count++ > 0 )) && (( width++ ))
  done
  REPLY=$width
}

function _plainlevel_left_width() {
  local width=0 i count=0
  for (( i = 3; i <= ${#_plainlevel_left_parts}; i += 4 )); do
    (( width += ${#_plainlevel_left_parts[i]} + 2 ))
    case ${_plainlevel_left_parts[i]} in
      ${PLAINLEVEL_HOME_ICON}${PLAINLEVEL_DIR_ICON_GAP}*)
        (( width += PLAINLEVEL_HOME_ICON_WIDTH - 1 ))
        ;;
      ${PLAINLEVEL_HOME_SUB_ICON}${PLAINLEVEL_DIR_ICON_GAP}*)
        (( width += PLAINLEVEL_HOME_SUB_ICON_WIDTH - 1 ))
        ;;
      ${PLAINLEVEL_FOLDER_ICON}${PLAINLEVEL_DIR_ICON_GAP}*)
        (( width += PLAINLEVEL_FOLDER_ICON_WIDTH - 1 ))
        ;;
    esac
    (( count++ > 0 )) && (( width++ ))
  done
  REPLY=$width
}

function _plainlevel_build_parts() {
  _plainlevel_left_parts=()
  _plainlevel_right_parts=()

  if _plainlevel_bool "$PLAINLEVEL_SHOW_OS"; then
    _plainlevel_os_name
    _plainlevel_add_left $PLAINLEVEL_OS_BG $PLAINLEVEL_OS_FG "$REPLY" false
  fi

  _plainlevel_directory
  _plainlevel_add_left $PLAINLEVEL_DIR_BG $PLAINLEVEL_DIR_FG "$REPLY" $PLAINLEVEL_DIR_BOLD

  if _plainlevel_git; then
    _plainlevel_add_left $reply[1] $reply[2] "$reply[3]" false
  fi

  if (( _plainlevel_last_status == 0 )); then
    _plainlevel_add_right $PLAINLEVEL_STATUS_BG $PLAINLEVEL_STATUS_OK_FG '✔'
  else
    _plainlevel_add_right $PLAINLEVEL_STATUS_BG $PLAINLEVEL_STATUS_ERROR_FG "✘ ${_plainlevel_last_status}"
  fi

  if (( _plainlevel_command_elapsed >= PLAINLEVEL_DURATION_THRESHOLD )); then
    local elapsed=${_plainlevel_command_elapsed%.*}
    _plainlevel_add_right $PLAINLEVEL_INFO_BG $PLAINLEVEL_DURATION_FG "${elapsed}s"
  fi

  (( ${#jobstates} > 0 )) &&
    _plainlevel_add_right $PLAINLEVEL_INFO_BG $PLAINLEVEL_INFO_FG "jobs ${#jobstates}"

  if _plainlevel_bool "$PLAINLEVEL_SHOW_VENV"; then
    if [[ -n ${VIRTUAL_ENV-} ]]; then
      local venv_name=${VIRTUAL_ENV:h:t}
      _plainlevel_add_right $PLAINLEVEL_INFO_BG $PLAINLEVEL_INFO_FG "${venv_name} ${PLAINLEVEL_VENV_ICON}"
    elif [[ -n ${CONDA_DEFAULT_ENV-} ]]; then
      _plainlevel_add_right $PLAINLEVEL_INFO_BG $PLAINLEVEL_INFO_FG "conda ${CONDA_DEFAULT_ENV}"
    fi
  fi

  if [[ ${PLAINLEVEL_SHOW_CONTEXT:l} == always ||
        ( ${PLAINLEVEL_SHOW_CONTEXT:l} == auto && ( -n ${SSH_CONNECTION-} || $EUID == 0 ) ) ]]; then
    _plainlevel_add_right $PLAINLEVEL_INFO_BG $PLAINLEVEL_INFO_FG "${USER:-%n}@${HOST%%.*}"
  fi

  if _plainlevel_bool "$PLAINLEVEL_SHOW_TIME"; then
    _plainlevel_add_right $PLAINLEVEL_INFO_BG $PLAINLEVEL_TIME_FG "$(strftime "$PLAINLEVEL_TIME_FORMAT")"
  fi
}

function _plainlevel_set_prompt() {
  local left right prefix gap gap_text left_width right_width
  _plainlevel_build_parts
  _plainlevel_left_width
  left_width=$REPLY
  _plainlevel_parts_width _plainlevel_right_parts
  right_width=$REPLY

  # Drop the least important rightmost segments on narrow terminals, just as
  # Keep right-prompt details from colliding with the left side.
  while (( ${#_plainlevel_right_parts} && left_width + right_width + 9 > COLUMNS )); do
    _plainlevel_right_parts[-3,-1]=()
    _plainlevel_parts_width _plainlevel_right_parts
    right_width=$REPLY
  done

  _plainlevel_render_left
  left=$REPLY
  _plainlevel_render_right
  right=$REPLY

  prefix="${_plainlevel_fg}${PLAINLEVEL_FRAME_COLOR}m%}╭─${_plainlevel_fg_reset}"
  (( gap = COLUMNS - left_width - right_width - 8 ))
  (( gap < 1 )) && gap=1
  printf -v gap_text '%*s' $gap ''

  if _plainlevel_bool "$PLAINLEVEL_TWO_LINES"; then
    PROMPT=''
    _plainlevel_bool "$PLAINLEVEL_ADD_NEWLINE" && PROMPT+=$'\n'
    PROMPT+="${prefix}${left}${gap_text}${right}"$'\n'
    if (( _plainlevel_last_status == 0 )); then
      PROMPT+="${_plainlevel_fg}${PLAINLEVEL_FRAME_COLOR}m%}╰─${_plainlevel_fg_reset} ${_plainlevel_fg}76m%}>${_plainlevel_fg_reset} "
    else
      PROMPT+="${_plainlevel_fg}${PLAINLEVEL_FRAME_COLOR}m%}╰─${_plainlevel_fg_reset} ${_plainlevel_fg}196m%}>${_plainlevel_fg_reset} "
    fi
  else
    PROMPT=''
    _plainlevel_bool "$PLAINLEVEL_ADD_NEWLINE" && PROMPT+=$'\n'
    PROMPT+="${left} "
    (( _plainlevel_last_status == 0 )) &&
      PROMPT+="${_plainlevel_fg}76m%}>${_plainlevel_fg_reset} " ||
      PROMPT+="${_plainlevel_fg}196m%}>${_plainlevel_fg_reset} "
    RPROMPT=$right
  fi
}

function _plainlevel_preexec() {
  _plainlevel_command_started=${EPOCHREALTIME:-$SECONDS}
}

function _plainlevel_precmd() {
  _plainlevel_last_status=$?
  if (( _plainlevel_command_started > 0 )); then
    (( _plainlevel_command_elapsed = ${EPOCHREALTIME:-$SECONDS} - _plainlevel_command_started ))
  else
    _plainlevel_command_elapsed=0
  fi
  _plainlevel_command_started=0
  _plainlevel_set_prompt
}

function plainlevel() {
  case ${1:-help} in
    configure)
      shift
      "$PLAINLEVEL_ROOT/bin/plainlevel-configure" "$@"
      ;;
    reload)
      source ${PLAINLEVEL_CONFIG:-$PLAINLEVEL_ROOT/config/plainlevel-classic.zsh}
      _plainlevel_set_prompt
      ;;
    version|--version|-v)
      print -r -- "plainlevel $PLAINLEVEL_VERSION"
      ;;
    help|--help|-h)
      print -r -- 'usage: plainlevel {configure|reload|version|help}'
      ;;
    *)
      print -u2 -r -- "plainlevel: unknown command: $1"
      return 2
      ;;
  esac
}

# Shelltone is the public command. Keep `plainlevel` above for existing setups.
function shelltone() {
  (( $# )) || set -- configure
  plainlevel "$@"
}

if [[ -o interactive ]]; then
  setopt prompt_subst
  add-zsh-hook -D preexec _plainlevel_preexec 2>/dev/null || true
  add-zsh-hook -D precmd _plainlevel_precmd 2>/dev/null || true
  add-zsh-hook preexec _plainlevel_preexec
  add-zsh-hook precmd _plainlevel_precmd
  RPROMPT=
  _plainlevel_set_prompt
fi
