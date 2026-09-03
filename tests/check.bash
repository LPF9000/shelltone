#!/usr/bin/env bash
set -euo pipefail

root=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
scratch=$(mktemp -d "${TMPDIR:-/tmp}/shelltone-test.XXXXXX")
trap 'rm -rf -- "$scratch"' EXIT

for file in "$root/shelltone.bash" "$root/shelltone-bash-sandbox.sh" "$root/bin/shelltone" "$root/bin/shelltone-configure" "$root/bin/try-shelltone"; do
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
printf 'ahead\n' > "$git_scratch/ahead"
git -C "$git_scratch" add ahead
git -C "$git_scratch" commit -qm ahead
printf 'staged\n' > "$git_scratch/staged"
git -C "$git_scratch" add staged
printf 'changed\n' >> "$git_scratch/tracked"
printf 'untracked\n' > "$git_scratch/untracked"

previous_directory=$PWD
cd "$git_scratch"
_shelltone_bash_git
[[ $SHELLTONE_BASH_GIT == *'⇡1'* && $SHELLTONE_BASH_GIT == *'+1'* && $SHELLTONE_BASH_GIT == *'!1'* && $SHELLTONE_BASH_GIT == *'?1'* ]]
[[ $SHELLTONE_BASH_GIT != *'⇢'* && $SHELLTONE_BASH_GIT != *'⇠'* ]]
cd "$previous_directory"
generated="$scratch/generated.sh"
for theme in tenfold afterglow night-shift northstar harbor sunset-strip; do
  "$root/bin/shelltone" configure --theme "$theme" --preset compact --output "$generated" >/dev/null
  bash -n "$generated"
  SHELLTONE_ROOT="$root" source "$generated"
  [[ $SHELLTONE_STYLE == "$theme" ]]
  [[ $SHELLTONE_TWO_LINES == false && $SHELLTONE_SHOW_TIME == false ]]
  [[ $SHELLTONE_GIT_AHEAD_FG != $SHELLTONE_GIT_BEHIND_FG ]]
  [[ $SHELLTONE_GIT_STAGED_FG != $SHELLTONE_GIT_CHANGED_FG ]]
  [[ $SHELLTONE_GIT_CHANGED_FG != $SHELLTONE_GIT_UNTRACKED_FG ]]
done

printf '%s\n' 'bash checks passed'
