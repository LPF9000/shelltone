<p align="center">
  <img src="./assets/shelltone-banner.png" alt="Shelltone" width="800">
</p>

<p align="center">
  A small, colorful Bash and Zsh prompt that looks good in the font you already use.
</p>

# Shelltone

[![Checks](https://github.com/LPF9000/shelltone/actions/workflows/ci.yml/badge.svg)](https://github.com/LPF9000/shelltone/actions/workflows/ci.yml)

Shelltone is a dependency-free Bash and Zsh prompt with a little bit of retro glow and none of the usual font ceremony. It is for people who want a useful prompt—not a dashboard bolted to their shell. No Nerd Font, no Powerline glyphs, no plugin manager, and no framework required.

It keeps the good parts close: the directory and Git branch on the left; command result, duration, jobs, environment, remote context, and clock on the right. When the terminal gets narrow, it quietly drops right-side details instead of wrapping your prompt into a mess.

## What it feels like

```text
╭─ ~/projects/shelltone ⎇ main ⇡1 +2 !1 ?1 ▓▒░       ░▒▓ ✔ · 4s · 11:17:04 AM
╰─ > git status
```

Start with **Tenfold**, **Afterglow**, **Night Shift**, **Northstar**, **Harbor**, or **Sunset Strip**. Pair any palette with **frame**, **pure**, **zen**, or **blocks** to independently choose the visual structure: bar, frame, dividers, fades, and prompt glyph. All of them use ordinary Unicode characters, so a normal Unicode-capable terminal font is enough.

## Try it without touching your shell

Clone the repository, then run:

```sh
./bin/try-shelltone --shell zsh
./bin/try-shelltone --shell bash
```

That opens a child shell with isolated startup files. It does not read or alter your regular shell configuration. Type `exit` when you are done; the temporary startup directory and its history go away with it.

The sandbox changes no startup file, alias, history file, or setting outside its disposable child shell. It is only for trying Shelltone’s prompt palettes and styles.

## Make it yours

Inside the sandbox, run the live configuration wizard. It presents color-coded palette cards, structural-style choices, and a live ANSI preview before writing anything:

```sh
shelltone configure
shelltone reload
```

It previews prompt height, spacing, clock format, and success/failure status before writing a config file. For a quick starting point:

```sh
./bin/shelltone configure --theme tenfold --style frame --preset classic
./bin/shelltone configure --theme night-shift --style pure --preset compact
```

By default this writes `config/shelltone.zsh`; pass `--output FILE` to keep a separate config. The settings are plain shell assignments and 256-color values, which makes new themes easy to add, copy, and tune without learning a mini language.

To enable it permanently, use the backup-first installer. It only appends a marked source line after confirmation and copies the startup file before changing it:

```sh
./bin/shelltone install zsh
./bin/shelltone install bash
```

Use `--dry-run` to inspect the target without changing files. Shelltone never replaces a startup file or changes any other shell configuration.

## Git at a glance

The Git segment reports only state that needs attention. Colors are theme-specific and intentionally distinct:

- `⇣` / `⇡` — commits behind or ahead of the upstream branch.
- `⇠` / `⇢` — commits behind or ahead of a separately configured push branch.
- `+` — staged files; `!` — modified files; `?` — untracked files.

This makes `⇣21 ⇡27 ⇠21 ⇢27 +6 !12 ?1` readable without turning the prompt into a full status screen.

## Optional alias packs

Shelltone never changes aliases unless asked. The sandbox enables the `starter` pack, which includes `ll`, `la`, `foldersize`, `projects`, and `reload`. Enable a pack explicitly in an existing shell:

```sh
shelltone aliases starter
shelltone aliases navigation
shelltone aliases git
```

## Themes, without bloat

Shelltone starts setup with a theme picker, then walks through that theme's layout, spacing, clock, and status choices before it writes anything. The [theme plan](./ROADMAP.md) keeps the future palette intentional: a few distinct, well-considered looks—not an endless cargo hold of modules.

## What is in here

- `shelltone.zsh` and `shelltone.bash` — small prompt engines behind the `shelltone` command.
- `config/shelltone.zsh` — the editable default theme configuration, shared by both shells.
- `themes/` — portable palette definitions.
- `shelltone-sandbox.zsh` and `shelltone-bash-sandbox.sh` — isolated child-shell startup logic.
- `shelltone-aliases.sh` — opt-in convenience packs.
- `bin/try-shelltone` — safe preview launcher.
- `bin/shelltone` — the public Shelltone command.
- `bin/shelltone-configure` — configuration wizard and presets.
- `tests/check.zsh` and `tests/check.bash` — syntax and behavior smoke checks.

Run the checks with:

```sh
./tests/check.bash
./tests/check.zsh
```
