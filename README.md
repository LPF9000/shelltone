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

Start with **Tenfold**, **Afterglow**, or **Night Shift**. Each has its own palette and can be set up as a full two-line prompt or a lean one-line prompt. All of them use ordinary Unicode characters, so a normal Unicode-capable terminal font is enough.

## Try it without touching your shell

Clone the repository, then run:

```zsh
./bin/try-plainlevel
```

That opens a child Zsh with a disposable `ZDOTDIR`. It does not read or alter `~/.zshrc`, does not load your usual Zsh configuration, and does not replace it. Type `exit` when you are done; the temporary startup directory and its history go away with it.

The sandbox also includes a few portable conveniences: colored `ls`, `ll`, `la`, `foldersize`, `projects`, and `reload`. They apply only to that test shell.

## Make it yours

Inside the sandbox, run the live configuration wizard:

```zsh
shelltone configure
shelltone reload
```

It previews prompt height, spacing, clock format, and success/failure status before writing a config file. For a quick starting point:

```zsh
./bin/shelltone configure --theme tenfold --preset classic
./bin/shelltone configure --theme night-shift --preset compact
```

By default this writes `config/plainlevel-classic.zsh`; pass `--output FILE` to keep a separate config. The settings are deliberately boring Zsh variables and 256-color values, which makes new themes easy to add, copy, and tune without learning a mini language.

## Themes, without bloat

Shelltone starts setup with a theme picker, then walks through that theme's layout, spacing, clock, and status choices before it writes anything. The [theme plan](./ROADMAP.md) keeps the future palette intentional: a few distinct, well-considered looks—not an endless cargo hold of modules.

## What is in here

- `plainlevel.zsh` — the small prompt engine behind the `shelltone` command.
- `config/plainlevel-classic.zsh` — the editable default theme configuration.
- `plainlevel-sandbox.zsh` — the isolated child-shell startup logic.
- `plainlevel-aliases.zsh` — sandbox-only conveniences.
- `bin/try-plainlevel` — safe preview launcher.
- `bin/shelltone` — the public Shelltone command.
- `bin/plainlevel-configure` — configuration wizard and presets.
- `tests/check.zsh` — syntax and behavior smoke checks.

Run the checks with:

```zsh
./tests/check.zsh
```

The older filenames and `plainlevel` command are kept only as a quiet compatibility layer for existing local setups. New instructions and new configurations use Shelltone.
