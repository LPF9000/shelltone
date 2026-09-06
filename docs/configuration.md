# Configuration reference

Shelltone reads plain shell assignments from `SHELLTONE_CONFIG`. The generated file can be edited directly. Source a palette before a layout so the layout can establish its own rendering state.

## Design choices

The curated design paths are `signal`, `still`, and `contour`. Custom configuration combines one of these palettes with a layout:

- Palettes: `tenfold`, `afterglow`, `night-shift`, `northstar`, `harbor`, `sunset-strip`.
- Layouts: `frame`, `pure`, `zen`, `blocks`.
- Presets: `classic` and `compact` for noninteractive setup.

```sh
./bin/shelltone configure --theme afterglow --style blocks --preset classic
```

## Common settings

| Setting | Default | Purpose |
| --- | --- | --- |
| `SHELLTONE_TWO_LINES` | `true` | Use a separate input line. |
| `SHELLTONE_ADD_NEWLINE` | `true` | Add breathing room before the prompt. |
| `SHELLTONE_SHOW_TIME` | `true` | Show the clock when space permits. |
| `SHELLTONE_SHOW_STATUS` | `true` | Show the previous command result. |
| `SHELLTONE_SHOW_DURATION` | `true` | Show commands over the threshold. |
| `SHELLTONE_DURATION_THRESHOLD` | `3` | Seconds before duration appears. Still and Contour use `5`. |
| `SHELLTONE_TIME_FORMAT` | `%I:%M:%S %p` | `strftime`/Bash time format. |
| `SHELLTONE_MAX_DIR_LENGTH` | `38` | Maximum path target for automatic abbreviation. |
| `SHELLTONE_PATH_MODE` | `auto` | `auto`, `full`, or `basename`. |
| `SHELLTONE_SHOW_CONTEXT` | `auto` | Show user and host always, never, or on SSH/root sessions. |
| `SHELLTONE_SHOW_VENV` | `true` | Show Python virtualenv or Conda context. |
| `SHELLTONE_GIT_ASYNC` | `true` | Defer Git collection in interactive shells. |
| `SHELLTONE_GIT_UNTRACKED` | `true` | Include untracked files in Git state. |
| `SHELLTONE_SHOW_GIT` | `true` | Enable Git collection. |
| `SHELLTONE_TRANSIENT` | `false` | Collapse submitted Zsh prompts to the prompt symbol. |

Set values after loading the selected palette and layout. `SHELLTONE_TRANSIENT` and vi-mode prompt symbols are Zsh behavior; Bash retains its normal line editing behavior.

## Git vocabulary

Signal displays counts and operation labels. Still uses a compact dirty marker and arrows. Contour uses presence markers for added, modified, deleted, renamed, conflicted, and untracked files. No prompt path performs an automatic `git fetch`.

## Terminal expectations

Shelltone uses ordinary Unicode and 256-color escape sequences. It does not require a patched font, but terminal font fallback determines how wide emoji and some symbols appear. The automated checks cover narrow columns and wide-character accounting; visual review should include an ordinary monospace font.
