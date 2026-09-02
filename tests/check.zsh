#!/usr/bin/env zsh
emulate -L zsh
setopt err_exit no_unset pipe_fail

local root=${0:A:h:h}
local scratch
scratch=$(mktemp -d ${TMPDIR:-/tmp}/plainlevel-test.XXXXXX)
trap 'rm -rf -- "$scratch"' EXIT

for file in "$root/plainlevel.zsh" "$root/plainlevel-sandbox.zsh" "$root/plainlevel-aliases.zsh" \
            "$root/bin/plainlevel" \
            "$root/bin/plainlevel-configure" "$root/bin/try-plainlevel"; do
  zsh -n "$file"
done

PLAINLEVEL_CONFIG="$root/config/plainlevel-classic.zsh" source "$root/plainlevel.zsh"
source "$root/plainlevel-aliases.zsh"
[[ "$(alias la)" == "la='ls -l -A --color=always'" ]]
[[ "$(alias ll)" == "ll='ls -l --color=always'" ]]
VIRTUAL_ENV=/tmp/riscv_pim/.venv
_plainlevel_last_status=7
_plainlevel_command_elapsed=4
COLUMNS=120
_plainlevel_set_prompt
[[ $PROMPT != *'LINUX'* ]]
[[ $PROMPT != *'node '* ]]
[[ $PROMPT == *'✘ 7'* ]]
[[ $PROMPT == *'4s'* ]]
[[ $PROMPT == *'riscv_pim 🐍'* ]]
[[ $PROMPT == *$'\e[38;5;'${PLAINLEVEL_DIR_FG}m* ]]
[[ $PROMPT == *"${_plainlevel_bold}~/plainlevel10k${_plainlevel_bold_reset}"* ]]
[[ $PROMPT == *$'\e[38;5;'${PLAINLEVEL_DURATION_FG}m* ]]
[[ $PROMPT == *$'\e[38;5;'${PLAINLEVEL_TIME_FG}m* ]]
[[ $PROMPT == *"${_plainlevel_bg}${PLAINLEVEL_INFO_BG}m%}${_plainlevel_fg}${PLAINLEVEL_SEPARATOR_FG}m%}·"* ]]
[[ $PROMPT == *'╭─'* ]]
[[ $PROMPT == *'╰─'* ]]
[[ $PROMPT == *'▓▒░'* ]]
[[ $PROMPT == *'░▒▓'* ]]
[[ $PROMPT != *$'\ue0b0'* ]]
[[ $PROMPT != *$'\uf000'* ]]

COLUMNS=45
_plainlevel_set_prompt
[[ $PROMPT == *'✘ 7'* ]]
[[ $PROMPT != *' AM'* ]]

_plainlevel_last_status=0
COLUMNS=120
_plainlevel_set_prompt
[[ $PROMPT == *'✔'* ]]
[[ $PROMPT != *'✘'* ]]

local previous_directory=$PWD
cd "$HOME"
_plainlevel_set_prompt
[[ $PROMPT == *"${_plainlevel_bold}~${_plainlevel_bold_reset}"* ]]
[[ $PROMPT != *'/home/ryanlaur'* ]]
cd "$previous_directory"

local git_scratch="$scratch/git-icons"
command git init -q "$git_scratch"
command git -C "$git_scratch" remote add origin git@github.com:plainlevel/demo.git
cd "$git_scratch"
_plainlevel_directory
[[ $REPLY == "$git_scratch" ]]
_plainlevel_git
[[ $reply[2] == $PLAINLEVEL_GIT_CLEAN_FG ]]
[[ $reply[3] == '⎇  '* ]]
[[ $reply[3] != *'GH'* ]]
cd "$previous_directory"

local generated="$scratch/generated.zsh"
"$root/bin/plainlevel-configure" --preset compact --output "$generated" >/dev/null
zsh -n "$generated"
source "$generated"
[[ $PLAINLEVEL_TWO_LINES == false ]]
[[ $PLAINLEVEL_ADD_NEWLINE == false ]]
[[ $PLAINLEVEL_SHOW_TIME == false ]]
[[ $PLAINLEVEL_SHOW_OS == false ]]
[[ $PLAINLEVEL_DIR_BG == 236 ]]
[[ $PLAINLEVEL_DIR_FG == 39 ]]
[[ $PLAINLEVEL_DIR_BOLD == true ]]
[[ $PLAINLEVEL_HOME_ICON == '🏠︎' ]]
[[ $PLAINLEVEL_HOME_ICON_FG == 39 ]]
[[ $PLAINLEVEL_HOME_SUB_ICON == '🗁' ]]
[[ $PLAINLEVEL_FOLDER_ICON == '🗁' ]]
[[ $PLAINLEVEL_DIR_ICON_GAP == '   ' ]]
[[ $PLAINLEVEL_SHOW_DIR_ICONS == false ]]
[[ $PLAINLEVEL_SHOW_GIT_ICON == true ]]
[[ $PLAINLEVEL_GIT_CLEAN_FG == 76 ]]
[[ $PLAINLEVEL_GIT_ICON == '⎇' ]]
[[ $PLAINLEVEL_DURATION_FG == 248 ]]
[[ $PLAINLEVEL_TIME_FG == 66 ]]
[[ $PLAINLEVEL_RIGHT_SEPARATOR == '·' ]]
[[ $PLAINLEVEL_VENV_ICON == '🐍' ]]

for theme in tenfold afterglow night-shift; do
  "$root/bin/shelltone" configure --theme "$theme" --preset compact --output "$generated" >/dev/null
  source "$generated"
  [[ $PLAINLEVEL_STYLE == "$theme" ]]
  [[ $PLAINLEVEL_OS_BG == $PLAINLEVEL_DIR_BG ]]
  [[ $PLAINLEVEL_DIR_BG == $PLAINLEVEL_GIT_CLEAN_BG ]]
  [[ $PLAINLEVEL_DIR_BG == $PLAINLEVEL_GIT_DIRTY_BG ]]
  [[ $PLAINLEVEL_DIR_BG == $PLAINLEVEL_INFO_BG ]]
  [[ $PLAINLEVEL_DIR_BG == $PLAINLEVEL_STATUS_BG ]]
  [[ $PLAINLEVEL_DIR_FG != $PLAINLEVEL_DIR_BG ]]
  [[ $PLAINLEVEL_GIT_CLEAN_FG != $PLAINLEVEL_GIT_CLEAN_BG ]]
  [[ $PLAINLEVEL_GIT_DIRTY_FG != $PLAINLEVEL_GIT_DIRTY_BG ]]
  [[ $PLAINLEVEL_TIME_FG != $PLAINLEVEL_INFO_BG ]]
done

# Guard the files the user explicitly asked us not to modify.
[[ -r "$HOME/.zshrc" ]]
[[ -r "$HOME/.p10k.zsh" ]]
print -- 'plainlevel checks passed'
