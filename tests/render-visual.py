#!/usr/bin/env python3
"""Render stable prompt SVG snapshots from the real Bash and Zsh engines."""
from __future__ import annotations

import html
from pathlib import Path
import re
import subprocess
import sys

ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / "tests" / "visual"
SCENARIOS = (("signal", "tenfold", "frame"), ("still", "still", "pure"), ("contour", "contour", "zen"))
ANSI = re.compile(r"\x1b\[[0-9;]*[A-Za-z]|[\x01\x02]")


def clean(value: str) -> list[str]:
    value = ANSI.sub("", value).replace("%{", "").replace("%}", "")
    return [line.rstrip() for line in value.splitlines() if line.strip()]


def render(shell: str, theme: str, style: str) -> list[str]:
    if shell == "zsh":
        code = (
            f'SHELLTONE_CONFIG=/dev/null; source {ROOT}/shelltone.zsh; '
            f'. {ROOT}/themes/{theme}.sh; . {ROOT}/layouts/{style}.sh; '
            'SHELLTONE_SHOW_GIT=false; SHELLTONE_SHOW_TIME=false; '
            'SHELLTONE_SHOW_STATUS=true; SHELLTONE_TWO_LINES=true; '
            'SHELLTONE_ADD_NEWLINE=false; cd /tmp; _shelltone_set_prompt; print -P -- "$PROMPT"'
        )
        command = ["zsh", "-f", "-c", code]
    else:
        code = (
            f'SHELLTONE_CONFIG=/dev/null; source {ROOT}/shelltone.bash; '
            f'. {ROOT}/themes/{theme}.sh; . {ROOT}/layouts/{style}.sh; '
            'SHELLTONE_SHOW_GIT=false; SHELLTONE_SHOW_TIME=false; '
            'SHELLTONE_SHOW_STATUS=true; SHELLTONE_TWO_LINES=true; '
            'SHELLTONE_ADD_NEWLINE=false; cd /tmp; _shelltone_bash_precmd; '
            'printf "%b\\n%b\\n" "$SHELLTONE_BASH_TOP" "$SHELLTONE_BASH_INPUT"'
        )
        command = ["bash", "--noprofile", "--norc", "-c", code]
    result = subprocess.run(command, check=True, text=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    return clean(result.stdout)


def svg(name: str, lines: list[str]) -> str:
    body = "\n".join(f'  <text x="24" y="{42 + i * 30}">{html.escape(line)}</text>' for i, line in enumerate(lines))
    return f'''<svg xmlns="http://www.w3.org/2000/svg" width="1200" height="120" viewBox="0 0 1200 120">
  <title>Shelltone {html.escape(name)} prompt</title>
  <rect width="1200" height="120" fill="#111827"/>
  <g fill="#f9fafb" font-family="DejaVu Sans Mono" font-size="20">
{body}
  </g>
</svg>
'''


def main() -> int:
    update = "--update" in sys.argv
    OUT.mkdir(parents=True, exist_ok=True)
    for name, theme, style in SCENARIOS:
        for shell in ("bash", "zsh"):
            filename = OUT / f"{name}-{shell}.svg"
            expected = svg(f"{name} {shell}", render(shell, theme, style))
            if update:
                filename.write_text(expected)
            elif not filename.exists() or filename.read_text() != expected:
                print(f"visual snapshot mismatch: {filename}", file=sys.stderr)
                return 1
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
