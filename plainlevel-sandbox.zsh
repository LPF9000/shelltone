# Deliberately not ~/.zshrc. The launcher sources this through a disposable bridge.
setopt interactive_comments
bindkey -e

# Keep test history in the launcher's disposable directory.
HISTFILE=${PLAINLEVEL_SANDBOX_HISTORY:?plainlevel launcher did not set sandbox history}
HISTSIZE=1000
SAVEHIST=1000
setopt append_history hist_ignore_dups

autoload -Uz compinit
compinit -d ${TMPDIR:-/tmp}/plainlevel-zcompdump-$ZSH_VERSION

source ${PLAINLEVEL_THEME:?plainlevel launcher did not set PLAINLEVEL_THEME}

print -P '%F{blue}Plainlevel10k sandbox%f -- your normal Zsh files and Powerlevel10k were not loaded.'
print -P 'Run %F{green}plainlevel configure%f to change the sandbox configuration; type %F{red}exit%f to leave.'
