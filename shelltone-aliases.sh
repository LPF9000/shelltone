# Optional Shelltone alias packs. Nothing is enabled until requested.

shelltone_aliases_enable() {
  case ${1:-starter} in
    starter)
      alias ls='ls --color=auto'
      alias ll='ls -l'
      alias la='ls -l -A'
      alias foldersize='du -sh .'
      alias projects='cd ~/projects'
      alias reload='shelltone reload'
      ;;
    navigation)
      alias ..='cd ..'
      alias ...='cd ../..'
      alias ....='cd ../../..'
      mkcd() { mkdir -p "$1" && cd "$1"; }
      ;;
    git)
      alias gs='git status --short --branch'
      alias glog='git log --oneline --decorate -12'
      alias groot='cd "$(git rev-parse --show-toplevel)"'
      ;;
    none) ;;
    *)
      printf '%s\n' "shelltone aliases: unknown pack: $1" >&2
      return 2
      ;;
  esac
}
