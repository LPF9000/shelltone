#!/usr/bin/env zsh
emulate -L zsh
setopt err_exit no_unset pipe_fail

local root=${0:A:h:h}
local scratch
scratch=$(mktemp -d ${TMPDIR:-/tmp}/shelltone-test.XXXXXX)
trap 'rm -rf -- "$scratch"' EXIT

for file in "$root/shelltone.zsh" "$root/shelltone-sandbox.zsh" "$root/shelltone-aliases.zsh" \
            "$root/bin/shelltone" \
            "$root/bin/shelltone-configure" "$root/bin/try-shelltone"; do
  zsh -n "$file"
done

SHELLTONE_CONFIG="$root/config/shelltone-classic.zsh" source "$root/shelltone.zsh"
source "$root/shelltone-aliases.zsh"
[[ "$(alias la)" == "la='ls -l -A --color=always'" ]]
[[ "$(alias ll)" == "ll='ls -l --color=always'" ]]
VIRTUAL_ENV=/tmp/riscv_pim/.venv
_shelltone_last_status=7
_shelltone_command_elapsed=4
COLUMNS=120
_shelltone_set_prompt
local prompt_directory="~/${PWD#$HOME/}"
[[ $PROMPT != *'LINUX'* ]]
[[ $PROMPT != *'node '* ]]
[[ $PROMPT == *'✘ 7'* ]]
[[ $PROMPT == *'4s'* ]]
[[ $PROMPT == *'riscv_pim 🐍'* ]]
[[ $PROMPT == *$'\e[38;5;'${SHELLTONE_DIR_FG}m* ]]
[[ $PROMPT == *"${_shelltone_bold}${prompt_directory}${_shelltone_bold_reset}"* ]]
[[ $PROMPT == *$'\e[38;5;'${SHELLTONE_DURATION_FG}m* ]]
[[ $PROMPT == *$'\e[38;5;'${SHELLTONE_TIME_FG}m* ]]
[[ $PROMPT == *"${_shelltone_bg}${SHELLTONE_INFO_BG}m%}${_shelltone_fg}${SHELLTONE_SEPARATOR_FG}m%}·"* ]]
[[ $PROMPT == *'╭─'* ]]
[[ $PROMPT == *'╰─'* ]]
[[ $PROMPT == *'▓▒░'* ]]
[[ $PROMPT == *'░▒▓'* ]]
[[ $PROMPT != *$'\ue0b0'* ]]
[[ $PROMPT != *$'\uf000'* ]]

COLUMNS=60
_shelltone_set_prompt
[[ $PROMPT != *' AM'* ]]

_shelltone_last_status=0
COLUMNS=120
_shelltone_set_prompt
[[ $PROMPT == *'✔'* ]]
[[ $PROMPT != *'✘'* ]]

local previous_directory=$PWD
cd "$HOME"
_shelltone_set_prompt
[[ $PROMPT == *"${_shelltone_bold}~${_shelltone_bold_reset}"* ]]
[[ $PROMPT != *'/home/ryanlaur'* ]]
cd "$previous_directory"

local git_scratch="$scratch/git-icons"
command git init -q "$git_scratch"
command git -C "$git_scratch" remote add origin git@github.com:shelltone/demo.git
cd "$git_scratch"
_shelltone_directory
[[ $REPLY == "$git_scratch" ]]
_shelltone_git
[[ $reply[2] == $SHELLTONE_GIT_CLEAN_FG ]]
[[ $reply[3] == '⎇  '* ]]
[[ $reply[3] != *'GH'* ]]
cd "$previous_directory"

local generated="$scratch/generated.zsh"
"$root/bin/shelltone-configure" --preset compact --output "$generated" >/dev/null
zsh -n "$generated"
source "$generated"
[[ $SHELLTONE_TWO_LINES == false ]]
[[ $SHELLTONE_ADD_NEWLINE == false ]]
[[ $SHELLTONE_SHOW_TIME == false ]]
[[ $SHELLTONE_SHOW_OS == false ]]
[[ $SHELLTONE_DIR_BG == 236 ]]
[[ $SHELLTONE_DIR_FG == 39 ]]
[[ $SHELLTONE_DIR_BOLD == true ]]
[[ $SHELLTONE_HOME_ICON == '🏠︎' ]]
[[ $SHELLTONE_HOME_ICON_FG == 39 ]]
[[ $SHELLTONE_HOME_SUB_ICON == '🗁' ]]
[[ $SHELLTONE_FOLDER_ICON == '🗁' ]]
[[ $SHELLTONE_DIR_ICON_GAP == '   ' ]]
[[ $SHELLTONE_SHOW_DIR_ICONS == false ]]
[[ $SHELLTONE_SHOW_GIT_ICON == true ]]
[[ $SHELLTONE_GIT_CLEAN_FG == 81 ]]
[[ $SHELLTONE_GIT_ICON == '⎇' ]]
[[ $SHELLTONE_DURATION_FG == 248 ]]
[[ $SHELLTONE_TIME_FG == 66 ]]
[[ $SHELLTONE_RIGHT_SEPARATOR == '·' ]]
[[ $SHELLTONE_VENV_ICON == '🐍' ]]

for theme in tenfold afterglow night-shift; do
  "$root/bin/shelltone" configure --theme "$theme" --preset compact --output "$generated" >/dev/null
  source "$generated"
  [[ $SHELLTONE_STYLE == "$theme" ]]
  [[ $SHELLTONE_OS_BG == $SHELLTONE_DIR_BG ]]
  [[ $SHELLTONE_DIR_BG == $SHELLTONE_GIT_CLEAN_BG ]]
  [[ $SHELLTONE_DIR_BG == $SHELLTONE_GIT_DIRTY_BG ]]
  [[ $SHELLTONE_DIR_BG == $SHELLTONE_INFO_BG ]]
  [[ $SHELLTONE_DIR_BG == $SHELLTONE_STATUS_BG ]]
  [[ $SHELLTONE_DIR_FG != $SHELLTONE_DIR_BG ]]
  [[ $SHELLTONE_GIT_CLEAN_FG != $SHELLTONE_GIT_CLEAN_BG ]]
  [[ $SHELLTONE_GIT_DIRTY_FG != $SHELLTONE_GIT_DIRTY_BG ]]
  [[ $SHELLTONE_GIT_CLEAN_FG != $SHELLTONE_DIR_FG ]]
  [[ $SHELLTONE_GIT_DIRTY_FG != $SHELLTONE_DIR_FG ]]
  [[ $SHELLTONE_GIT_CLEAN_FG != $SHELLTONE_GIT_DIRTY_FG ]]
  [[ $SHELLTONE_TIME_FG != $SHELLTONE_INFO_BG ]]
done

# Guard the files the user explicitly asked us not to modify.
[[ -r "$HOME/.zshrc" ]]
[[ -r "$HOME/.p10k.zsh" ]]
print -- 'shelltone checks passed'
