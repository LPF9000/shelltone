# Shelltone roadmap

Shelltone is a small, colorful Bash and Zsh prompt. Its three curated design paths are **Signal** (Powerlevel10k-inspired), **Still** (Pure-inspired), and **Contour** (Purity-inspired). The six palettes available in Custom are **Tenfold**, **Afterglow**, **Night Shift**, **Northstar**, **Harbor**, and **Sunset Strip**. Layouts and palettes stay separate so a custom choice does not require a new prompt engine.

## Complete

- Cross-shell rendering with shared shell assignments and four layouts: frame, pure, zen, and blocks.
- Curated design paths and six selectable palettes, with compact and two-line previews.
- Git branch, upstream and push movement, dirty counts, conflicts, stashes, and operation labels where the selected path supports them.
- Asynchronous Git refresh in interactive shells, a synchronous fallback, and controls for untracked-file scanning and Git visibility.
- Preset-specific paths: full home-relative paths for Still, basename paths for Contour, and lightweight parent abbreviation for Signal.
- Safe reloads, isolated preview shells, immediate configuration application, repeated-source handling, and preserved third-party highlighting.
- Oh My Zsh/plugin-manager loading through `shelltone.plugin.zsh`.
- Bash and Zsh smoke checks plus interactive lifecycle, compatibility, narrow-terminal, visual, and display-width regression checks.
- Configuration and framework integration references, deterministic SVG snapshots, and a three-context redraw benchmark.

## Next milestone

- Expand visual snapshots to cover more palettes and custom layouts, including background treatment and right-edge spacing.
- Add review artifacts rendered with a fixed ordinary monospace font when ImageMagick is available.
- Test real framework installations periodically in addition to the isolated loading harness.
- Compare benchmark results across platforms and shell versions.
- Test ordinary unpatched monospace fonts manually for glyph fallback issues.

## Deferred

- A `shelltone doctor` command.
- Automatic remote fetching from the prompt.
- A broad module catalog for language versions, cloud contexts, and other dashboards.
- New palettes until an existing design path needs one.

Every new behavior should remain optional, preserve a fast prompt path, work in both shells when practical, and include a compact and two-line validation case.
