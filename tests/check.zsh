#!/usr/bin/env zsh
emulate -L zsh
setopt err_exit no_unset pipe_fail

local root=${0:A:h:h}
local scratch
scratch=$(mktemp -d ${TMPDIR:-/tmp}/shelltone-test.XXXXXX)
trap 'rm -rf -- "$scratch"' EXIT

for file in "$root/shelltone.zsh" "$root/shelltone-sandbox.zsh" "$root/bin/shelltone" "$root/bin/shelltone-configure" "$root/bin/try-shelltone"; do
  zsh -n "$file"
done

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
for theme in tenfold afterglow night-shift northstar harbor sunset-strip; do
  "$root/bin/shelltone" configure --theme "$theme" --preset compact --output "$generated" >/dev/null
  zsh -n "$generated"
  source "$generated"
  [[ $SHELLTONE_STYLE == "$theme" ]]
  [[ $SHELLTONE_TWO_LINES == false && $SHELLTONE_SHOW_TIME == false ]]
  [[ $SHELLTONE_GIT_AHEAD_FG != $SHELLTONE_GIT_BEHIND_FG ]]
  [[ $SHELLTONE_GIT_STAGED_FG != $SHELLTONE_GIT_CHANGED_FG ]]
  [[ $SHELLTONE_GIT_CHANGED_FG != $SHELLTONE_GIT_UNTRACKED_FG ]]
done

SHELLTONE_CONFIG="$scratch/active.sh"
typeset +x SHELLTONE_CONFIG
shelltone configure --theme harbor --preset compact >/dev/null
[[ $SHELLTONE_THEME == harbor && $SHELLTONE_TWO_LINES == false ]]

local sandbox_output
sandbox_output=$(print exit | "$root/bin/try-shelltone" --shell zsh 2>&1)
[[ $sandbox_output == *'Shelltone sandbox'* && $sandbox_output == *'⎇'* ]]

print -- 'zsh checks passed'
