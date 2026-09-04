#!/usr/bin/env zsh
emulate -L zsh
setopt err_exit no_unset pipe_fail

local root=${0:A:h:h}
local scratch
scratch=$(mktemp -d ${TMPDIR:-/tmp}/shelltone-test.XXXXXX)
trap 'rm -rf -- "$scratch"' EXIT

for file in "$root/shelltone.zsh" "$root/shelltone-sandbox.zsh" "$root/bin/shelltone" "$root/bin/shelltone-configure" "$root/bin/shelltone-install" "$root/bin/try-shelltone"; do
  zsh -n "$file"
done

SHELLTONE_CONFIG="$scratch/initial.sh"
print 'SHELLTONE_THEME=tenfold
. "$SHELLTONE_ROOT/themes/$SHELLTONE_THEME.sh"
. "$SHELLTONE_ROOT/layouts/frame.sh"' > "$SHELLTONE_CONFIG"
source "$root/shelltone.zsh"
source "$root/shelltone.zsh"
source "$root/shelltone-aliases.sh"
shelltone_aliases_enable starter
[[ "$(alias ls)" == "ls='ls --color=auto'" ]]
[[ "$(alias la)" == "la='ls -l -A'" ]]

VIRTUAL_ENV=/tmp/demo/.venv
_shelltone_last_status=7
_shelltone_command_elapsed=4
COLUMNS=120
_shelltone_set_prompt
[[ $PROMPT == *'✘ 7'* && $PROMPT == *'4s'* && $PROMPT == *'demo 🐍'* ]]
[[ $PROMPT == *'╭─'* && $PROMPT == *'╰─'* && $PROMPT == *'▓▒░'* && $PROMPT == *'░▒▓'* ]]
[[ $PROMPT == *'⎇'* ]]

local git_scratch="$scratch/git" remote="$scratch/remote.git"
command git init -q "$git_scratch"
command git -C "$git_scratch" config user.name Shelltone
command git -C "$git_scratch" config user.email shelltone@example.invalid
print base > "$git_scratch/tracked"
command git -C "$git_scratch" add tracked
command git -C "$git_scratch" commit -qm initial
command git init --bare -q "$remote"
command git -C "$git_scratch" remote add origin "$remote"
command git -C "$git_scratch" push -qu origin HEAD
command git -C "$git_scratch" branch --set-upstream-to=origin/$(command git -C "$git_scratch" branch --show-current) >/dev/null

local previous_directory=$PWD
cd "$git_scratch"
_shelltone_git
local labels='' i
for (( i = 3; i <= ${#_shelltone_git_parts}; i += 4 )); do
  labels+=" ${_shelltone_git_parts[i]}"
done
[[ $labels == *'⎇'* && $labels != *'⇡'* && $labels != *'+'* && $labels != *'!'* && $labels != *'?'* ]]
_shelltone_set_prompt
[[ $PROMPT == *'⎇'* ]]
cd "$previous_directory"

print ahead > "$git_scratch/ahead"
command git -C "$git_scratch" add ahead
command git -C "$git_scratch" commit -qm ahead
print staged > "$git_scratch/staged"
command git -C "$git_scratch" add staged
print changed >> "$git_scratch/tracked"
print untracked > "$git_scratch/untracked"

cd "$git_scratch"
_shelltone_git
labels=''
for (( i = 3; i <= ${#_shelltone_git_parts}; i += 4 )); do
  labels+=" ${_shelltone_git_parts[i]}"
done
[[ $labels == *'⇡1'* && $labels == *'+1'* && $labels == *'!1'* && $labels == *'?1'* ]]
[[ $labels != *'⇢'* && $labels != *'⇠'* ]]
cd "$previous_directory"

local generated="$scratch/generated.sh" theme
for style in frame pure zen blocks; do
  [[ -r "$root/layouts/$style.sh" ]]
done
for theme in tenfold afterglow night-shift northstar harbor sunset-strip; do
  "$root/bin/shelltone" configure --theme "$theme" --style frame --preset compact --output "$generated" >/dev/null
  zsh -n "$generated"
  source "$generated"
  [[ $SHELLTONE_STYLE == "$theme" ]]
  [[ $SHELLTONE_PROMPT_STYLE == frame && $SHELLTONE_SHOW_BAR == true ]]
  [[ $SHELLTONE_TWO_LINES == false && $SHELLTONE_SHOW_TIME == false ]]
  [[ $SHELLTONE_OS_BG == $SHELLTONE_BAR_BG && $SHELLTONE_DIR_BG == $SHELLTONE_BAR_BG ]]
  [[ $SHELLTONE_GIT_CLEAN_BG == $SHELLTONE_BAR_BG && $SHELLTONE_GIT_DIRTY_BG == $SHELLTONE_BAR_BG ]]
  [[ $SHELLTONE_INFO_BG == $SHELLTONE_BAR_BG && $SHELLTONE_STATUS_BG == $SHELLTONE_BAR_BG ]]
  [[ $SHELLTONE_GIT_AHEAD_FG != $SHELLTONE_GIT_BEHIND_FG ]]
  [[ $SHELLTONE_GIT_STAGED_FG != $SHELLTONE_GIT_CHANGED_FG ]]
  [[ $SHELLTONE_GIT_CHANGED_FG != $SHELLTONE_GIT_UNTRACKED_FG ]]
  SHELLTONE_TWO_LINES=true
  cd "$git_scratch"
  _shelltone_set_prompt
  cd "$previous_directory"
  [[ $PROMPT == *"${_shelltone_fg}${SHELLTONE_FRAME_COLOR}m%}"* ]]
  [[ $PROMPT == *"${_shelltone_bg}${SHELLTONE_BAR_BG}m%}"* ]]
  [[ $PROMPT == *"${_shelltone_fg}${SHELLTONE_DIR_FG}m%}"* ]]
  [[ $PROMPT == *"${_shelltone_fg}${SHELLTONE_GIT_CLEAN_FG}m%} ⎇"* ]]
  if [[ $theme == tenfold ]]; then
    [[ $SHELLTONE_DIR_BOLD == true && $PROMPT == *"${_shelltone_bold}"* ]]
  else
    [[ $SHELLTONE_DIR_BOLD == false && $PROMPT != *"${_shelltone_bold}"* ]]
  fi
done

for theme in still contour; do
  [[ -r "$root/themes/$theme.sh" ]]
done

for style in pure zen blocks; do
  "$root/bin/shelltone" configure --theme afterglow --style "$style" --preset compact --output "$generated" >/dev/null
  source "$generated"
  [[ $SHELLTONE_PROMPT_STYLE == "$style" ]]
  [[ -n $SHELLTONE_PROMPT_SYMBOL ]]
done

local preview_output
preview_output=$(print '4\n2\n1\n1\n2\n1\n2\n1\n1\n1' | "$root/bin/shelltone-configure" --output "$scratch/preview.sh")
[[ $preview_output == *$'\e[38;5;87m>⎇ main '* ]]
[[ $preview_output == *'DESIGN PATH'* && $preview_output == *'BAR TREATMENT'* && $preview_output == *'BAR SHADE'* ]]
[[ $(grep -c 'LIVE PREVIEW' <<< "$preview_output") -ge 14 ]]
[[ $preview_output == *'YOUR CHOICE'* && $preview_output == *'› '* ]]
! grep -q 'civis' "$root/bin/shelltone-configure"
preview_output=$(print '4\n1\n1\n1\n1\n2\n2\n1\n1\n1' | "$root/bin/shelltone-configure" --output "$scratch/preview.sh")
[[ $preview_output == *$'\e[1m ~/projects \e[22m'* ]]
preview_output=$(print '4\n4\n3' | "$root/bin/shelltone-configure" --output "$scratch/preview.sh")
[[ $preview_output == *'northstar / zen'* && $preview_output == *'S H E L L T O N E'* ]]
[[ $preview_output != *'BAR TREATMENT'* && $preview_output != *'CLOCK'* ]]
source "$scratch/preview.sh"
[[ $SHELLTONE_THEME == northstar && $SHELLTONE_PROMPT_STYLE == zen && $SHELLTONE_DESIGN_PATH == custom ]]

preview_output=$(print '2' | "$root/bin/shelltone-configure" --output "$scratch/preview.sh")
source "$scratch/preview.sh"
[[ $SHELLTONE_DESIGN_PATH == still && $SHELLTONE_THEME == still && $SHELLTONE_PROMPT_STYLE == pure ]]
[[ $SHELLTONE_SHOW_BAR == false && $SHELLTONE_SHOW_TIME == false && $SHELLTONE_SHOW_STATUS == false && $SHELLTONE_SHOW_DURATION == false ]]
[[ $SHELLTONE_DIR_FG == 4 && $SHELLTONE_GIT_CLEAN_FG == 242 && $SHELLTONE_GIT_AHEAD_FG == 6 && $SHELLTONE_DURATION_FG == 3 && $SHELLTONE_STATUS_OK_FG == 5 && $SHELLTONE_STATUS_ERROR_FG == 1 ]]
[[ $SHELLTONE_GIT_DETAIL == false && $SHELLTONE_PROMPT_SUCCESS_FG == 5 && $SHELLTONE_PROMPT_ERROR_FG == 1 ]]

SHELLTONE_CONFIG="$scratch/active.sh"
typeset +x SHELLTONE_CONFIG
shelltone configure --theme harbor --preset compact >/dev/null
[[ $SHELLTONE_THEME == harbor && $SHELLTONE_TWO_LINES == false ]]

local sandbox_output
sandbox_output=$(print exit | "$root/bin/try-shelltone" --shell zsh 2>&1)
[[ $sandbox_output == *'Shelltone sandbox'* && $sandbox_output == *'⎇'* ]]

local install_output
install_output=$(ZDOTDIR="$scratch/zdot" "$root/bin/shelltone" install zsh --dry-run)
[[ $install_output == *"would append Shelltone to $scratch/zdot/.zshrc" ]]

print -- 'zsh checks passed'
