# Shelltone theme plan

Shelltone stays small on purpose. A theme should feel like a considered prompt, not a pile of unrelated status widgets.

## Available now

- **Tenfold** — the bright, framed, two-line signature look. Its name is a wink at the family of big-number prompt themes without borrowing their implementation.
- **Afterglow** — magenta, peach, and cyan for a late-night terminal.
- **Night Shift** — cool blues and restrained contrast for long sessions.

The setup wizard begins with these choices, previews the selected palette, then asks about line height, spacing, and clock format. Noninteractive setup uses `shelltone configure --theme NAME --preset classic|compact`.

Every theme should show Git state with a shared vocabulary: `⇣` and `⇡` for upstream movement, `⇠` and `⇢` for push movement, `+` for staged files, `!` for changed files, and `?` for untracked files. Each marker must have a distinct, palette-fitting color.

## Next themes

- Cross-shell rendering and shared, portable theme configuration are in place.
- Optional alias packs are available without changing a shell unless explicitly enabled.
- Checks run against both supported shells and validate every included theme.

## Next refinements

- Add an optional, clearly labeled abbreviated-directory mode for deep paths.
- Add a Figlet-style, slanted Shelltone banner for the first-run experience and installer, with a compact plain-text fallback for narrow terminals.
- Add theme screenshots generated from the sandbox for visual regression review.

## Prompt compatibility hardening

Use the established prompt ecosystems as a continuing review set before expanding Shelltone behavior:

- **State isolation:** every theme and layout must explicitly establish its full rendering state, so switching paths in a live shell cannot retain a previous path's colors, Git format, prompt symbol, or syntax treatment.
- **Sandbox isolation:** `try-shelltone` must copy all writable configuration and history into its temporary directory. Add regression coverage proving that a configure session cannot alter the source configuration.
- **Immediate application:** `shelltone configure` must redraw the selected prompt in the current shell without requiring a manual reload. Exercise transitions between every curated path and Custom in both Bash and Zsh checks.
- **Graceful integration:** document source ordering for Oh My Zsh and other prompt frameworks, detect incompatible prompt ownership where practical, and degrade optional integrations to an empty segment instead of failing.
- **Terminal capability fallbacks:** keep ordinary Unicode as the baseline; test narrow terminals, non-TTY setup, limited color support, and missing optional shell facilities.
- **Responsive Git state:** profile prompt redraws in large repositories, cache or defer expensive Git work, and retain a fast synchronous fallback when asynchronous work is unavailable.
- **Visual contracts:** preserve snapshot-like ANSI previews for every numbered wizard choice and add scenario checks for colors, prompt symbol state, bar treatment, and right-edge behavior.

## Prompt styles

Palette themes and prompt styles are deliberately separate. A palette controls color; a style controls the bar, frames, dividers, fades, clock treatment, and prompt glyph. The initial set is **frame**, **pure**, **zen**, and **blocks**. Future styles should stay font-independent and should be recognizable at a glance without copying another prompt's exact composition.

## Artwork follow-up

The current README banner deliberately uses the original full-color PNG. The first SVG experiment retained the letter shapes but flattened the cyan, red, cream, gradient, and scanline treatment into one color, so it is not suitable as the project mark. Revisit vector artwork only with a workflow that preserves those color layers and effects; until then, the PNG is the canonical banner.

## Repository history cleanup

Remove retired product names and upstream attributions from every reachable repository surface: files, commit messages, branch names, tags, release notes, pull-request titles and bodies, discussion comments, and generated documentation.

1. Inventory all reachable references and export a backup before any rewrite.
2. Rewrite local history with a repeatable mapping, then verify that no retired terms remain in reachable revisions.
3. Coordinate a protected-branch window, force-push the rewritten references, and update or replace affected review records.
4. Ask every contributor to replace existing local clones; old clones can reintroduce retired history.

Before a new theme lands, it needs a distinct palette, a compact and two-line preview, and a configuration path that works without a custom font. The names can nod to the prompt culture that inspired the look, but the design and implementation remain Shelltone's own.
