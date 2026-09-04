# Shelltone prompt engine. Uses ordinary terminal characters and no custom font.
# Source this file from zsh. It has no dependencies and does not require a patched font.

[[ -n ${ZSH_VERSION-} ]] || return 1

typeset -g SHELLTONE_ROOT=${${(%):-%N}:A:h}
typeset -gx SHELLTONE_CONFIG=${SHELLTONE_CONFIG:-$SHELLTONE_ROOT/config/shelltone.zsh}
typeset -g SHELLTONE_VERSION=0.1.0

[[ -r $SHELLTONE_CONFIG ]] && source "$SHELLTONE_CONFIG"

# Defaults also make the theme usable with a tiny or partially written config.
: ${SHELLTONE_STYLE:=classic}
: ${SHELLTONE_PROMPT_STYLE:=frame}
: ${SHELLTONE_COLOR_DEPTH:=256}
: ${SHELLTONE_TWO_LINES:=true}
: ${SHELLTONE_ADD_NEWLINE:=true}
: ${SHELLTONE_SHOW_TIME:=true}
: ${SHELLTONE_SHOW_STATUS:=true}
: ${SHELLTONE_SHOW_DURATION:=true}
: ${SHELLTONE_TIME_FORMAT:=%I:%M:%S %p}
: ${SHELLTONE_SHOW_CONTEXT:=auto}
: ${SHELLTONE_SHOW_VENV:=true}
: ${SHELLTONE_VENV_ICON:=🐍}
: ${SHELLTONE_SHOW_OS:=false}
: ${SHELLTONE_DURATION_THRESHOLD:=3}
: ${SHELLTONE_MAX_DIR_LENGTH:=38}
: ${SHELLTONE_BAR_BG:=236}
: ${SHELLTONE_FRAME_COLOR:=240}
: ${SHELLTONE_SEPARATOR_FG:=244}
: ${SHELLTONE_RIGHT_SEPARATOR:=·}
: ${SHELLTONE_SHOW_BAR:=true}
: ${SHELLTONE_LEFT_DIVIDER:=>}
: ${SHELLTONE_RIGHT_DIVIDER:=$SHELLTONE_RIGHT_SEPARATOR}
: ${SHELLTONE_LEFT_FADE:=▓▒░}
: ${SHELLTONE_RIGHT_FADE:=░▒▓}
: ${SHELLTONE_TOP_PREFIX:=╭─}
: ${SHELLTONE_INPUT_PREFIX:=╰─}
: ${SHELLTONE_PROMPT_SYMBOL:=>}
: ${SHELLTONE_FADE_FG:=236}
: ${SHELLTONE_OS_BG:=$SHELLTONE_BAR_BG}
: ${SHELLTONE_OS_FG:=255}
: ${SHELLTONE_DIR_BG:=$SHELLTONE_BAR_BG}
: ${SHELLTONE_DIR_FG:=39}
: ${SHELLTONE_DIR_BOLD:=true}
: ${SHELLTONE_HOME_ICON:=🏠︎}
: ${SHELLTONE_HOME_ICON_WIDTH:=2}
: ${SHELLTONE_HOME_ICON_FG:=39}
: ${SHELLTONE_HOME_SUB_ICON:=🗁}
: ${SHELLTONE_HOME_SUB_ICON_WIDTH:=2}
: ${SHELLTONE_HOME_SUB_ICON_FG:=39}
: ${SHELLTONE_FOLDER_ICON:=🗁}
: ${SHELLTONE_FOLDER_ICON_WIDTH:=2}
: ${SHELLTONE_FOLDER_ICON_FG:=39}
: ${SHELLTONE_DIR_ICON_GAP:='   '}
: ${SHELLTONE_GIT_CLEAN_BG:=$SHELLTONE_BAR_BG}
: ${SHELLTONE_GIT_CLEAN_FG:=81}
: ${SHELLTONE_GIT_DIRTY_BG:=$SHELLTONE_BAR_BG}
: ${SHELLTONE_GIT_DIRTY_FG:=220}
: ${SHELLTONE_GIT_AHEAD_FG:=81}
: ${SHELLTONE_GIT_BEHIND_FG:=214}
: ${SHELLTONE_GIT_PUSH_AHEAD_FG:=117}
: ${SHELLTONE_GIT_PUSH_BEHIND_FG:=178}
: ${SHELLTONE_GIT_STAGED_FG:=75}
: ${SHELLTONE_GIT_CHANGED_FG:=215}
: ${SHELLTONE_GIT_UNTRACKED_FG:=203}
: ${SHELLTONE_GIT_ICON:=⎇}
: ${SHELLTONE_SHOW_DIR_ICONS:=false}
: ${SHELLTONE_SHOW_GIT_ICON:=true}
: ${SHELLTONE_INFO_BG:=$SHELLTONE_BAR_BG}
: ${SHELLTONE_INFO_FG:=39}
: ${SHELLTONE_DURATION_FG:=248}
: ${SHELLTONE_TIME_FG:=66}
: ${SHELLTONE_STATUS_BG:=$SHELLTONE_BAR_BG}
: ${SHELLTONE_STATUS_OK_FG:=70}
: ${SHELLTONE_STATUS_ERROR_FG:=160}

autoload -Uz add-zsh-hook
zmodload zsh/datetime 2>/dev/null || true

typeset -g _shelltone_last_status=0
typeset -gF _shelltone_command_started=0
typeset -gF _shelltone_command_elapsed=0
typeset -ga _shelltone_left_parts _shelltone_right_parts _shelltone_git_parts
typeset -g _shelltone_fg=$'%{\e[38;5;'
typeset -g _shelltone_bg=$'%{\e[48;5;'
typeset -g _shelltone_fg_reset=$'%{\e[39m%}'
typeset -g _shelltone_bg_reset=$'%{\e[49m%}'
typeset -g _shelltone_bold=$'%{\e[1m%}'
typeset -g _shelltone_bold_reset=$'%{\e[22m%}'

function _shelltone_escape_prompt() {
  REPLY=${1//\%/%%}
}

function _shelltone_bool() {
  [[ ${1:l} == (1|true|yes|on) ]]
}

function _shelltone_add_left() {
  _shelltone_escape_prompt "$3"
  _shelltone_left_parts+=("$1" "$2" "$REPLY" "${4:-false}")
}

function _shelltone_add_right() {
  _shelltone_escape_prompt "$3"
  _shelltone_right_parts+=("$1" "$2" "$REPLY")
}

function _shelltone_os_name() {
  case $OSTYPE in
    linux*)   REPLY=LINUX ;;
    darwin*)  REPLY=MAC ;;
    freebsd*) REPLY=BSD ;;
    cygwin*)  REPLY=CYGWIN ;;
    msys*)    REPLY=MSYS ;;
    *)        REPLY=UNIX ;;
  esac
}

function _shelltone_directory() {
  local shown icon icon_width
  if [[ $PWD == $HOME ]]; then
    shown='~'
    icon=$SHELLTONE_HOME_ICON
    icon_width=$SHELLTONE_HOME_ICON_WIDTH
  elif [[ $PWD == $HOME/* ]]; then
    shown="~/${PWD#$HOME/}"
    icon=$SHELLTONE_HOME_SUB_ICON
    icon_width=$SHELLTONE_HOME_SUB_ICON_WIDTH
  else
    shown=$PWD
    icon=$SHELLTONE_FOLDER_ICON
    icon_width=$SHELLTONE_FOLDER_ICON_WIDTH
  fi
  local max=$SHELLTONE_MAX_DIR_LENGTH
  if (( ${#shown} > max )); then
    shown="...${shown[-$((max - 3)),-1]}"
  fi
  if _shelltone_bool "$SHELLTONE_SHOW_DIR_ICONS" && [[ -n $icon ]]; then
    REPLY="${icon}${SHELLTONE_DIR_ICON_GAP}${shown}"
  else
    REPLY=$shown
  fi
}

function _shelltone_git() {
  local root branch porcelain ahead=0 behind=0 push_ahead=0 push_behind=0 prefix=''
  local upstream_ref='' push_ref=''
  local staged=0 changed=0 untracked=0 line index worktree
  root=$(command git rev-parse --show-toplevel 2>/dev/null) || return 1
  branch=$(command git symbolic-ref --quiet --short HEAD 2>/dev/null) ||
    branch="@$(command git rev-parse --short HEAD 2>/dev/null)"
  porcelain=$(command git status --porcelain --untracked-files=normal 2>/dev/null)
  local counts
  counts=$(command git rev-list --left-right --count '@{upstream}...HEAD' 2>/dev/null) || counts=''
  if [[ -n $counts ]]; then
    behind=${counts%%[[:space:]]*}
    ahead=${counts##*[[:space:]]}
    :
  fi
  upstream_ref=$(command git rev-parse --symbolic-full-name '@{upstream}' 2>/dev/null) || upstream_ref=''
  push_ref=$(command git rev-parse --symbolic-full-name '@{push}' 2>/dev/null) || push_ref=''
  if [[ -n $push_ref && $push_ref != $upstream_ref ]]; then
    counts=$(command git rev-list --left-right --count '@{push}...HEAD' 2>/dev/null) || counts=''
    if [[ -n $counts ]]; then
      push_behind=${counts%%[[:space:]]*}
      push_ahead=${counts##*[[:space:]]}
    fi
  fi
  if _shelltone_bool "$SHELLTONE_SHOW_GIT_ICON" && [[ -n $SHELLTONE_GIT_ICON ]]; then
    prefix="${SHELLTONE_GIT_ICON}  "
  fi
  while IFS= read -r line; do
    [[ -z $line ]] && continue
    if [[ ${line[1,2]} == '??' ]]; then
      (( ++untracked ))
      continue
    fi
    index=${line[1]}
    worktree=${line[2]}
    [[ $index != ' ' ]] && (( ++staged ))
    [[ $worktree != ' ' ]] && (( ++changed ))
  done <<< "$porcelain"

  _shelltone_git_parts=()
  _shelltone_git_parts+=($SHELLTONE_GIT_CLEAN_BG $SHELLTONE_GIT_CLEAN_FG "${prefix}${branch}" false)
  (( behind > 0 )) && _shelltone_git_parts+=($SHELLTONE_GIT_CLEAN_BG $SHELLTONE_GIT_BEHIND_FG "⇣${behind}" false)
  (( ahead > 0 )) && _shelltone_git_parts+=($SHELLTONE_GIT_CLEAN_BG $SHELLTONE_GIT_AHEAD_FG "⇡${ahead}" false)
  (( push_behind > 0 )) && _shelltone_git_parts+=($SHELLTONE_GIT_CLEAN_BG $SHELLTONE_GIT_PUSH_BEHIND_FG "⇠${push_behind}" false)
  (( push_ahead > 0 )) && _shelltone_git_parts+=($SHELLTONE_GIT_CLEAN_BG $SHELLTONE_GIT_PUSH_AHEAD_FG "⇢${push_ahead}" false)
  (( staged > 0 )) && _shelltone_git_parts+=($SHELLTONE_GIT_CLEAN_BG $SHELLTONE_GIT_STAGED_FG "+${staged}" false)
  (( changed > 0 )) && _shelltone_git_parts+=($SHELLTONE_GIT_CLEAN_BG $SHELLTONE_GIT_CHANGED_FG "!${changed}" false)
  (( untracked > 0 )) && _shelltone_git_parts+=($SHELLTONE_GIT_CLEAN_BG $SHELLTONE_GIT_UNTRACKED_FG "?${untracked}" false)
  return 0
}

function _shelltone_render_left() {
  local out='' bg fg label bold icon icon_fg rest i first=true
  for (( i = 1; i <= ${#_shelltone_left_parts}; i += 4 )); do
    bg=${_shelltone_left_parts[i]}
    fg=${_shelltone_left_parts[i + 1]}
    label=${_shelltone_left_parts[i + 2]}
    bold=${_shelltone_left_parts[i + 3]}
    _shelltone_bool "$SHELLTONE_SHOW_BAR" && out+="${_shelltone_bg}${bg}m%}"
    if [[ $first == false ]]; then
      out+="${_shelltone_fg}${SHELLTONE_SEPARATOR_FG}m%}${SHELLTONE_LEFT_DIVIDER}"
    fi
    icon=''
    icon_fg=$fg
    case $label in
      ${SHELLTONE_HOME_ICON}${SHELLTONE_DIR_ICON_GAP}*)
        icon=$SHELLTONE_HOME_ICON
        icon_fg=$SHELLTONE_HOME_ICON_FG
        rest=${label#$icon}
        ;;
      ${SHELLTONE_HOME_SUB_ICON}${SHELLTONE_DIR_ICON_GAP}*)
        icon=$SHELLTONE_HOME_SUB_ICON
        icon_fg=$SHELLTONE_HOME_SUB_ICON_FG
        rest=${label#$icon}
        ;;
      ${SHELLTONE_FOLDER_ICON}${SHELLTONE_DIR_ICON_GAP}*)
        icon=$SHELLTONE_FOLDER_ICON
        icon_fg=$SHELLTONE_FOLDER_ICON_FG
        rest=${label#$icon}
        ;;
    esac
    out+="${_shelltone_fg}${fg}m%} "
    _shelltone_bool "$bold" && out+="${_shelltone_bold}"
    if [[ -n $icon ]]; then
      out+="${_shelltone_fg}${icon_fg}m%}${icon}${_shelltone_fg}${fg}m%}${rest}"
    else
      out+="${label}"
    fi
    _shelltone_bool "$bold" && out+="${_shelltone_bold_reset}"
    out+=' '
    first=false
  done
  [[ -n $out && -n $SHELLTONE_LEFT_FADE ]] &&
    out+="${_shelltone_bg_reset}${_shelltone_fg}${SHELLTONE_FADE_FG}m%}${SHELLTONE_LEFT_FADE}${_shelltone_fg_reset}"
  REPLY=$out
}

function _shelltone_render_right() {
  local out='' bg fg label i first=true
  [[ -n $SHELLTONE_RIGHT_FADE ]] && out="${_shelltone_fg}${SHELLTONE_FADE_FG}m%}${SHELLTONE_RIGHT_FADE}${_shelltone_fg_reset}"
  for (( i = 1; i <= ${#_shelltone_right_parts}; i += 3 )); do
    bg=${_shelltone_right_parts[i]}
    fg=${_shelltone_right_parts[i + 1]}
    label=${_shelltone_right_parts[i + 2]}
    _shelltone_bool "$SHELLTONE_SHOW_BAR" && out+="${_shelltone_bg}${bg}m%}"
    if [[ $first == false ]]; then
      out+="${_shelltone_fg}${SHELLTONE_SEPARATOR_FG}m%}${SHELLTONE_RIGHT_DIVIDER}"
    fi
    out+="${_shelltone_fg}${fg}m%} ${label} "
    first=false
  done
  [[ -n $out ]] && out+="${_shelltone_bg_reset}${_shelltone_fg_reset}"
  REPLY=$out
}

function _shelltone_parts_width() {
  local -a parts=("${(@P)1}")
  local width=0 i count=0
  for (( i = 3; i <= ${#parts}; i += 3 )); do
    (( width += ${#parts[i]} + 2 ))
    (( count++ > 0 )) && (( width++ ))
  done
  REPLY=$width
}

function _shelltone_left_width() {
  local width=0 i count=0
  for (( i = 3; i <= ${#_shelltone_left_parts}; i += 4 )); do
    (( width += ${#_shelltone_left_parts[i]} + 2 ))
    case ${_shelltone_left_parts[i]} in
      ${SHELLTONE_HOME_ICON}${SHELLTONE_DIR_ICON_GAP}*)
        (( width += SHELLTONE_HOME_ICON_WIDTH - 1 ))
        ;;
      ${SHELLTONE_HOME_SUB_ICON}${SHELLTONE_DIR_ICON_GAP}*)
        (( width += SHELLTONE_HOME_SUB_ICON_WIDTH - 1 ))
        ;;
      ${SHELLTONE_FOLDER_ICON}${SHELLTONE_DIR_ICON_GAP}*)
        (( width += SHELLTONE_FOLDER_ICON_WIDTH - 1 ))
        ;;
    esac
    (( count++ > 0 )) && (( width++ ))
  done
  REPLY=$width
}

function _shelltone_build_parts() {
  _shelltone_left_parts=()
  _shelltone_right_parts=()

  if _shelltone_bool "$SHELLTONE_SHOW_OS"; then
    _shelltone_os_name
    _shelltone_add_left $SHELLTONE_OS_BG $SHELLTONE_OS_FG "$REPLY" false
  fi

  _shelltone_directory
  _shelltone_add_left $SHELLTONE_DIR_BG $SHELLTONE_DIR_FG "$REPLY" $SHELLTONE_DIR_BOLD

  if _shelltone_git; then
    _shelltone_left_parts+=($_shelltone_git_parts)
  fi

  if _shelltone_bool "$SHELLTONE_SHOW_STATUS"; then
    if (( _shelltone_last_status == 0 )); then
      _shelltone_add_right $SHELLTONE_STATUS_BG $SHELLTONE_STATUS_OK_FG '✔'
    else
      _shelltone_add_right $SHELLTONE_STATUS_BG $SHELLTONE_STATUS_ERROR_FG "✘ ${_shelltone_last_status}"
    fi
  fi

  if _shelltone_bool "$SHELLTONE_SHOW_DURATION" && (( _shelltone_command_elapsed >= SHELLTONE_DURATION_THRESHOLD )); then
    local elapsed=${_shelltone_command_elapsed%.*}
    _shelltone_add_right $SHELLTONE_INFO_BG $SHELLTONE_DURATION_FG "${elapsed}s"
  fi

  (( ${#jobstates} > 0 )) &&
    _shelltone_add_right $SHELLTONE_INFO_BG $SHELLTONE_INFO_FG "jobs ${#jobstates}"

  if _shelltone_bool "$SHELLTONE_SHOW_VENV"; then
    if [[ -n ${VIRTUAL_ENV-} ]]; then
      local venv_name=${VIRTUAL_ENV:h:t}
      _shelltone_add_right $SHELLTONE_INFO_BG $SHELLTONE_INFO_FG "${venv_name} ${SHELLTONE_VENV_ICON}"
    elif [[ -n ${CONDA_DEFAULT_ENV-} ]]; then
      _shelltone_add_right $SHELLTONE_INFO_BG $SHELLTONE_INFO_FG "conda ${CONDA_DEFAULT_ENV}"
    fi
  fi

  if [[ ${SHELLTONE_SHOW_CONTEXT:l} == always ||
        ( ${SHELLTONE_SHOW_CONTEXT:l} == auto && ( -n ${SSH_CONNECTION-} || $EUID == 0 ) ) ]]; then
    _shelltone_add_right $SHELLTONE_INFO_BG $SHELLTONE_INFO_FG "${USER:-%n}@${HOST%%.*}"
  fi

  if _shelltone_bool "$SHELLTONE_SHOW_TIME"; then
    _shelltone_add_right $SHELLTONE_INFO_BG $SHELLTONE_TIME_FG "$(strftime "$SHELLTONE_TIME_FORMAT")"
  fi
}

function _shelltone_set_prompt() {
  local left right prefix gap gap_text left_width right_width
  _shelltone_build_parts
  _shelltone_left_width
  left_width=$REPLY
  _shelltone_parts_width _shelltone_right_parts
  right_width=$REPLY

  # Keep right-prompt details from colliding with the left side.
  while (( ${#_shelltone_right_parts} && left_width + right_width + 9 > COLUMNS )); do
    _shelltone_right_parts[-3,-1]=()
    _shelltone_parts_width _shelltone_right_parts
    right_width=$REPLY
  done

  _shelltone_render_left
  left=$REPLY
  _shelltone_render_right
  right=$REPLY

  prefix="${_shelltone_fg}${SHELLTONE_FRAME_COLOR}m%}${SHELLTONE_TOP_PREFIX}${_shelltone_fg_reset}"
  (( gap = COLUMNS - left_width - right_width - ${#SHELLTONE_TOP_PREFIX} - 6 ))
  (( gap < 1 )) && gap=1
  printf -v gap_text '%*s' $gap ''

  if _shelltone_bool "$SHELLTONE_TWO_LINES"; then
    PROMPT=''
    _shelltone_bool "$SHELLTONE_ADD_NEWLINE" && PROMPT+=$'\n'
    PROMPT+="${prefix}${left}${gap_text}${right}"$'\n'
    if (( _shelltone_last_status == 0 )); then
      PROMPT+="${_shelltone_fg}${SHELLTONE_FRAME_COLOR}m%}${SHELLTONE_INPUT_PREFIX}${_shelltone_fg_reset} ${_shelltone_fg}76m%}${SHELLTONE_PROMPT_SYMBOL}${_shelltone_fg_reset} "
    else
      PROMPT+="${_shelltone_fg}${SHELLTONE_FRAME_COLOR}m%}${SHELLTONE_INPUT_PREFIX}${_shelltone_fg_reset} ${_shelltone_fg}196m%}${SHELLTONE_PROMPT_SYMBOL}${_shelltone_fg_reset} "
    fi
  else
    PROMPT=''
    _shelltone_bool "$SHELLTONE_ADD_NEWLINE" && PROMPT+=$'\n'
    PROMPT+="${left} "
    (( _shelltone_last_status == 0 )) &&
      PROMPT+="${_shelltone_fg}76m%}${SHELLTONE_PROMPT_SYMBOL}${_shelltone_fg_reset} " ||
      PROMPT+="${_shelltone_fg}196m%}${SHELLTONE_PROMPT_SYMBOL}${_shelltone_fg_reset} "
    RPROMPT=$right
  fi
}

function _shelltone_preexec() {
  _shelltone_command_started=${EPOCHREALTIME:-$SECONDS}
}

function _shelltone_precmd() {
  _shelltone_last_status=$?
  if (( _shelltone_command_started > 0 )); then
    (( _shelltone_command_elapsed = ${EPOCHREALTIME:-$SECONDS} - _shelltone_command_started ))
  else
    _shelltone_command_elapsed=0
  fi
  _shelltone_command_started=0
  _shelltone_set_prompt
}

function shelltone() {
  case ${1:-configure} in
    configure)
      shift
      SHELLTONE_CONFIG="$SHELLTONE_CONFIG" "$SHELLTONE_ROOT/bin/shelltone-configure" "$@" && shelltone reload
      ;;
    reload)
      source "$SHELLTONE_CONFIG"
      _shelltone_set_prompt
      ;;
    aliases)
      shift
      source "$SHELLTONE_ROOT/shelltone-aliases.sh"
      shelltone_aliases_enable "${1:-starter}"
      ;;
    themes)
      local theme
      for theme in "$SHELLTONE_ROOT"/themes/*.sh; do
        print -r -- "${theme:t:r}"
      done
      ;;
    styles)
      local layout
      for layout in "$SHELLTONE_ROOT"/layouts/*.sh; do
        print -r -- "${layout:t:r}"
      done
      ;;
    install)
      shift
      command "$SHELLTONE_ROOT/bin/shelltone" install "$@"
      ;;
    version|--version|-v)
      print -r -- "shelltone $SHELLTONE_VERSION"
      ;;
    help|--help|-h)
      print -r -- 'usage: shelltone {configure|reload|aliases|themes|styles|install|version|help}'
      ;;
    *)
      print -u2 -r -- "shelltone: unknown command: $1"
      return 2
      ;;
  esac
}

if [[ -o interactive ]]; then
  setopt prompt_subst
  add-zsh-hook -D preexec _shelltone_preexec 2>/dev/null || true
  add-zsh-hook -D precmd _shelltone_precmd 2>/dev/null || true
  add-zsh-hook preexec _shelltone_preexec
  add-zsh-hook precmd _shelltone_precmd
  RPROMPT=
  _shelltone_set_prompt
fi
