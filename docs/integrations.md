# Framework integration

Shelltone is a prompt plugin, not a framework. Load it after the framework has loaded its plugins and disable that framework's prompt theme. Only one prompt engine should own `PROMPT`, `RPROMPT`, or `PROMPT_COMMAND`.

## Plain Zsh

```zsh
source /path/to/shelltone/shelltone.plugin.zsh
```

## Oh My Zsh

```zsh
ZSH_THEME=""
plugins=(git)
source "$ZSH/oh-my-zsh.sh"
source /path/to/shelltone/shelltone.plugin.zsh
```

To load it through Oh My Zsh's plugin list, link the repository as `$ZSH_CUSTOM/plugins/shelltone`; the `shelltone.plugin.zsh` file is the entry point. Do not set another `ZSH_THEME`.

## Prezto

Leave Prezto's prompt theme unset and source `shelltone.plugin.zsh` after Prezto initialization. Shelltone does not require Prezto's Git helpers.

## Antidote, Zinit, and similar managers

Load the repository as a normal plugin, using `shelltone.plugin.zsh` as its entry point. If the manager has a separate theme command, use its plugin or source mechanism instead so Shelltone loads after the manager's normal initialization.

## Bash

```bash
source /path/to/shelltone/shelltone.bash
```

Shelltone preserves existing `PROMPT_COMMAND` entries on first load and installs its renderer as the active prompt hook. Bash 4.4 or newer is required.

## Troubleshooting

If another prompt remains visible, unset its theme or source Shelltone later. If Git details are slow, set `SHELLTONE_GIT_ASYNC=true` (the default), `SHELLTONE_GIT_UNTRACKED=false`, or `SHELLTONE_SHOW_GIT=false`. Set `SHELLTONE_GIT_ASYNC=false` when diagnosing a repository and testing deterministic output.
