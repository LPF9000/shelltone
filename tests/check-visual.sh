#!/usr/bin/env bash
set -euo pipefail

root=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
python3 "$root/tests/render-visual.py"

if command -v convert >/dev/null 2>&1; then
  scratch=$(mktemp -d "${TMPDIR:-/tmp}/shelltone-visual.XXXXXX")
  trap 'rm -rf -- "$scratch"' EXIT
  for svg in "$root"/tests/visual/*.svg; do
    convert -background '#111827' -font DejaVu-Sans-Mono "$svg" "$scratch/$(basename "${svg%.svg}").png" 2>/dev/null
  done
fi

printf '%s\n' 'visual snapshots passed'
