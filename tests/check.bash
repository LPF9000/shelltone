#!/usr/bin/env bash
set -euo pipefail

root=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
scratch=$(mktemp -d "${TMPDIR:-/tmp}/shelltone-test.XXXXXX")
trap 'rm -rf -- "$scratch"' EXIT

for file in "$root/shelltone.bash" "$root/shelltone-bash-sandbox.sh" "$root/bin/shelltone" "$root/bin/shelltone-configure" "$root/bin/shelltone-install" "$root/bin/try-shelltone"; do
  bash -n "$file"
done

source "$root/shelltone.bash"
source "$root/shelltone-aliases.sh"
shelltone_aliases_enable starter
[[ $(alias ls) == "alias ls='ls --color=auto'" ]]
[[ $(alias la) == "alias la='ls -l -A'" ]]

git_scratch="$scratch/git"
remote="$scratch/remote.git"
git init -q "$git_scratch"
git -C "$git_scratch" config user.name Shelltone
git -C "$git_scratch" config user.email shelltone@example.invalid
printf 'base\n' > "$git_scratch/tracked"
git -C "$git_scratch" add tracked
git -C "$git_scratch" commit -qm initial
git init --bare -q "$remote"
git -C "$git_scratch" remote add origin "$remote"
git -C "$git_scratch" push -qu origin HEAD
git -C "$git_scratch" branch --set-upstream-to="origin/$(git -C "$git_scratch" branch --show-current)" >/dev/null

previous_directory=$PWD
cd "$git_scratch"
_shelltone_bash_git
[[ $SHELLTONE_BASH_GIT == *'⎇'* && $SHELLTONE_BASH_GIT != *'⇡'* && $SHELLTONE_BASH_GIT != *'+'* && $SHELLTONE_BASH_GIT != *'!'* && $SHELLTONE_BASH_GIT != *'?'* ]]
cd "$previous_directory"

printf 'ahead\n' > "$git_scratch/ahead"
git -C "$git_scratch" add ahead
git -C "$git_scratch" commit -qm ahead
printf 'staged\n' > "$git_scratch/staged"
git -C "$git_scratch" add staged
printf 'changed\n' >> "$git_scratch/tracked"
printf 'untracked\n' > "$git_scratch/untracked"

cd "$git_scratch"
_shelltone_bash_git
[[ $SHELLTONE_BASH_GIT == *'⇡1'* && $SHELLTONE_BASH_GIT == *'+1'* && $SHELLTONE_BASH_GIT == *'!1'* && $SHELLTONE_BASH_GIT == *'?1'* ]]
[[ $SHELLTONE_BASH_GIT != *'⇢'* && $SHELLTONE_BASH_GIT != *'⇠'* ]]
cd "$previous_directory"
generated="$scratch/generated.sh"
for style in frame pure zen blocks; do
  [[ -r "$root/layouts/$style.sh" ]]
done
for theme in tenfold afterglow night-shift northstar harbor sunset-strip; do
  "$root/bin/shelltone" configure --theme "$theme" --style frame --preset compact --output "$generated" >/dev/null
  bash -n "$generated"
  SHELLTONE_ROOT="$root" source "$generated"
  [[ $SHELLTONE_STYLE == "$theme" ]]
  [[ $SHELLTONE_PROMPT_STYLE == frame && $SHELLTONE_SHOW_BAR == true ]]
  [[ $SHELLTONE_TWO_LINES == false && $SHELLTONE_SHOW_TIME == false ]]
  [[ $SHELLTONE_OS_BG == "$SHELLTONE_BAR_BG" && $SHELLTONE_DIR_BG == "$SHELLTONE_BAR_BG" ]]
  [[ $SHELLTONE_GIT_CLEAN_BG == "$SHELLTONE_BAR_BG" && $SHELLTONE_GIT_DIRTY_BG == "$SHELLTONE_BAR_BG" ]]
  [[ $SHELLTONE_INFO_BG == "$SHELLTONE_BAR_BG" && $SHELLTONE_STATUS_BG == "$SHELLTONE_BAR_BG" ]]
  [[ $SHELLTONE_GIT_AHEAD_FG != $SHELLTONE_GIT_BEHIND_FG ]]
  [[ $SHELLTONE_GIT_STAGED_FG != $SHELLTONE_GIT_CHANGED_FG ]]
  [[ $SHELLTONE_GIT_CHANGED_FG != $SHELLTONE_GIT_UNTRACKED_FG ]]
  cd "$git_scratch"
  _shelltone_bash_precmd
  cd "$previous_directory"
  [[ $SHELLTONE_BASH_TOP == *"38;5;${SHELLTONE_FRAME_COLOR}m"* ]]
  [[ $SHELLTONE_BASH_TOP == *"48;5;${SHELLTONE_BAR_BG}m"* ]]
  [[ $SHELLTONE_BASH_TOP == *"38;5;${SHELLTONE_DIR_FG}m"* ]]
  [[ $SHELLTONE_BASH_GIT == *"38;5;${SHELLTONE_GIT_CLEAN_FG}m\\] ⎇"* ]]
  if [[ $theme == tenfold ]]; then
    [[ $SHELLTONE_DIR_BOLD == true && $SHELLTONE_BASH_TOP == *"${_shelltone_bash_bold}"* ]]
  else
    [[ $SHELLTONE_DIR_BOLD == false && $SHELLTONE_BASH_TOP != *"${_shelltone_bash_bold}"* ]]
  fi
done

preview_output=$(printf '4\n3\n1\nn\nn\nn\n' | "$root/bin/shelltone-configure" --output "$scratch/preview.sh")
[[ $preview_output == *'northstar / zen'* && $preview_output == *'S H E L L T O N E'* ]]
[[ $preview_output == *'YOUR CHOICE'* && $preview_output == *'› '* ]]
! grep -q 'civis' "$root/bin/shelltone-configure"
source "$scratch/preview.sh"
[[ $SHELLTONE_THEME == northstar && $SHELLTONE_PROMPT_STYLE == zen && $SHELLTONE_SHOW_TIME == false && $SHELLTONE_SHOW_STATUS == false && $SHELLTONE_SHOW_DURATION == false ]]

for style in pure zen blocks; do
  "$root/bin/shelltone" configure --theme afterglow --style "$style" --preset compact --output "$generated" >/dev/null
  source "$generated"
  [[ $SHELLTONE_PROMPT_STYLE == "$style" ]]
  [[ -n $SHELLTONE_PROMPT_SYMBOL ]]
done

SHELLTONE_CONFIG="$scratch/active.sh"
export -n SHELLTONE_CONFIG
shelltone configure --theme harbor --preset compact >/dev/null
[[ $SHELLTONE_THEME == harbor && $SHELLTONE_TWO_LINES == false ]]

sandbox_output=$(printf 'exit\n' | "$root/bin/try-shelltone" --shell bash 2>&1)
[[ $sandbox_output == *'Shelltone Bash sandbox'* && $sandbox_output == *'⎇'* ]]

install_output=$(ZDOTDIR="$scratch/zdot" "$root/bin/shelltone" install zsh --dry-run)
[[ $install_output == *"would append Shelltone to $scratch/zdot/.zshrc" ]]

printf '%s\n' 'bash checks passed'
