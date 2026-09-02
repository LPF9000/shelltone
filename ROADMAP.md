# Shelltone theme plan

Shelltone stays small on purpose. A theme should feel like a considered prompt, not a pile of unrelated status widgets.

## Available now

- **Tenfold** — the bright, framed, two-line signature look. Its name is a wink at the family of big-number prompt themes without borrowing their implementation.
- **Afterglow** — magenta, peach, and cyan for a late-night terminal.
- **Night Shift** — cool blues and restrained contrast for long sessions.

The setup wizard begins with these choices, previews the selected palette, then asks about line height, spacing, and clock format. Noninteractive setup uses `shelltone configure --theme NAME --preset classic|compact`.

## Next themes

- **Northstar** — crisp arctic blue with a compact, information-first rhythm.
- **Harbor** — quiet sea-glass colors and a calm single-line default.
- **Sunset Strip** — warm terminal glow with a deliberately minimal right prompt.

## Artwork follow-up

The current README banner deliberately uses the original full-color PNG. The first SVG experiment retained the letter shapes but flattened the cyan, red, cream, gradient, and scanline treatment into one color, so it is not suitable as the project mark. Revisit vector artwork only with a workflow that preserves those color layers and effects; until then, the PNG is the canonical banner.

## Repository history cleanup

Remove retired product names and upstream attributions from every reachable repository surface: files, commit messages, branch names, tags, release notes, pull-request titles and bodies, discussion comments, and generated documentation.

1. Inventory all reachable references and export a backup before any rewrite.
2. Rewrite local history with a repeatable mapping, then verify that no retired terms remain in reachable revisions.
3. Coordinate a protected-branch window, force-push the rewritten references, and update or replace affected review records.
4. Ask every contributor to replace existing local clones; old clones can reintroduce retired history.

Before a new theme lands, it needs a distinct palette, a compact and two-line preview, and a configuration path that works without a custom font. The names can nod to the prompt culture that inspired the look, but the design and implementation remain Shelltone's own.
