# Plainlevel10k

Plainlevel10k is a dependency-free Zsh prompt inspired by the layout and setup experience of
Powerlevel10k's classic prompt. It uses only ordinary text and standard Unicode box/block symbols,
so it works with normal Unicode-capable terminal fonts and never needs a Nerd Font or Powerline
glyphs.

The default prompt has two lines. The first shows the current directory in bold light blue and Git
state on a dark-gray bar. Home is displayed as `~`, without directory icons. Clean Git branches use
Powerlevel10k's green and retain the standard Unicode branch marker.
Command status (`✔` or `✘` plus the exit code), duration, background jobs,
Python/Conda environment, remote context, and time appear on the right. The second line contains the
command marker. Standard `╭─`/`╰─` frame characters, `▓▒░`/`░▒▓` faded tails, and the outlined `◁`
right-side separator reproduce the classic visual rhythm without private-use font characters.

## Try it safely

From this directory, run:

```zsh
./bin/try-plainlevel
```

This starts a child Zsh with a temporary `ZDOTDIR`. It does not read or alter `~/.zshrc`, does not
load Oh My Zsh, and does not load, replace, or configure Powerlevel10k. Zsh itself insists that an
interactive startup bridge be named `.zshrc`; the launcher creates that bridge only in a fresh
temporary directory and deletes it, along with the sandbox history, when the child shell exits. The
maintained startup file is `plainlevel-sandbox.zsh`.

Type `exit` to return to the normal shell.

## Configure it

Inside the sandbox, run:

```zsh
plainlevel configure
plainlevel reload
```

The interactive wizard clears the screen for each choice and renders live examples for prompt
height, spacing, clock format, success status, and failure status before it writes anything.

For a noninteractive setup:

```zsh
./bin/plainlevel configure --preset classic
./bin/plainlevel configure --preset compact
```

Both commands write only `config/plainlevel-classic.zsh` in this project unless `--output FILE`
is supplied. The configuration variables are intentionally straightforward and documented by
their names; colors use Zsh's built-in 256-color palette.

## Files

- `plainlevel.zsh`: theme engine and `plainlevel` command.
- `config/plainlevel-classic.zsh`: isolated theme configuration.
- `plainlevel-sandbox.zsh`: isolated child-shell startup logic.
- `bin/try-plainlevel`: safe preview launcher.
- `bin/plainlevel-configure`: setup wizard.
- `tests/check.zsh`: syntax and behavior smoke checks.

Run checks with `./tests/check.zsh`.
