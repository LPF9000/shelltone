<p align="center">
  <img src="./assets/shelltone-banner.png" alt="Shelltone" width="800">
</p>

<p align="center">
  A small, colorful Zsh prompt that looks good in the font you already use.
</p>

# Shelltone

Shelltone is a dependency-free Zsh prompt with a little bit of retro glow and none of the usual font ceremony. It is for people who want a useful prompt—not a dashboard bolted to their shell. No Nerd Font, no Powerline glyphs, no plugin manager, and no framework required.

It keeps the good parts close: the directory and Git branch on the left; command result, duration, jobs, environment, remote context, and clock on the right. When the terminal gets narrow, it quietly drops right-side details instead of wrapping your prompt into a mess.

## What it feels like

```text
╭─ ~/projects/shelltone ▓▒░                 ░▒▓ ✔ · 4s · 11:17:04 AM
╰─ > git status
```

The default **classic** look is two lines with the familiar faded tails and a calm dark bar. The included **compact** preset puts the same information on one line and leaves out the clock. Both use ordinary Unicode characters, so a normal Unicode-capable terminal font is enough.

## Try it without touching your shell

Clone the repository, then run:

```zsh
./bin/try-plainlevel
```

That opens a child Zsh with a disposable `ZDOTDIR`. It does not read or alter `~/.zshrc`, does not load Oh My Zsh, and does not replace or configure Powerlevel10k. Type `exit` when you are done; the temporary startup directory and its history go away with it.

The sandbox also includes a few portable conveniences: colored `ls`, `ll`, `la`, `foldersize`, `projects`, and `reload`. They apply only to that test shell.

## Make it yours

Inside the sandbox, run the live configuration wizard:

```zsh
plainlevel configure
plainlevel reload
```

It previews prompt height, spacing, clock format, and success/failure status before writing a config file. For a quick starting point:

```zsh
./bin/plainlevel configure --preset classic
./bin/plainlevel configure --preset compact
```

By default this writes `config/plainlevel-classic.zsh`; pass `--output FILE` to keep a separate config. The settings are deliberately boring Zsh variables and 256-color values, which makes new themes easy to add, copy, and tune without learning a mini language.

## Themes, without bloat

Classic and compact are the starting palette, not the ceiling. Shelltone is intentionally a small theme engine: a theme is just a readable configuration file, so future looks can change color, spacing, segments, and line height without turning the prompt into a heavy framework. The goal is a few distinct, well-considered themes—not an endless cargo hold of modules.

## What is in here

- `plainlevel.zsh` — the small prompt engine and `plainlevel` command.
- `config/plainlevel-classic.zsh` — the editable default theme configuration.
- `plainlevel-sandbox.zsh` — the isolated child-shell startup logic.
- `plainlevel-aliases.zsh` — sandbox-only conveniences.
- `bin/try-plainlevel` — safe preview launcher.
- `bin/plainlevel-configure` — configuration wizard and presets.
- `tests/check.zsh` — syntax and behavior smoke checks.

Run the checks with:

```zsh
./tests/check.zsh
```

## A small note on the name

The project is now Shelltone. The existing `plainlevel` command, filenames, and configuration variables remain in place for now so current setups and scripts do not break; they are the compatibility layer beneath the new name.
