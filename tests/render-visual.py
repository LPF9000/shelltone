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
SCENARIOS = (
    ("signal", "tenfold", "frame"),
    ("signal-blocks", "afterglow", "blocks"),
    ("still", "still", "pure"),
    ("contour", "contour", "zen"),
)
ANSI = re.compile(r"\x1b\[([0-9;]*)m|[\x01\x02]")
XTERM = (0, 95, 135, 175, 215, 255)


def color(index: int) -> str:
    if index < 16:
        base = ((0, 0, 0), (205, 0, 0), (0, 205, 0), (205, 205, 0), (0, 0, 238),
                (205, 0, 205), (0, 205, 205), (229, 229, 229), (127, 127, 127),
                (255, 0, 0), (0, 255, 0), (255, 255, 0), (92, 92, 255),
                (255, 0, 255), (0, 255, 255), (255, 255, 255))[index]
    elif index < 232:
        value = index - 16
        base = (XTERM[value // 36], XTERM[value // 6 % 6], XTERM[value % 6])
    else:
        base = (8 + (index - 232) * 10,) * 3
    return "#%02x%02x%02x" % base


def clean(value: str) -> list[list[tuple[str, str]]]:
    lines = []
    for raw in value.splitlines():
        state = "#f9fafb"
        parts = []
        position = 0
        for match in ANSI.finditer(raw):
            text = raw[position:match.start()].replace("%{", "").replace("%}", "")
            if text:
                parts.append((state, text))
            codes = [int(code) for code in (match.group(1) or "0").split(";") if code]
            if not codes or 0 in codes:
                state = "#f9fafb"
            for code in codes:
                if 30 <= code <= 37:
                    state = color(code - 30)
                elif 90 <= code <= 97:
                    state = color(code - 90 + 8)
                elif code == 39:
                    state = "#f9fafb"
                elif code == 38 and len(codes) >= 3 and codes[1] == 5:
                    state = color(codes[2])
            position = match.end()
        tail = raw[position:].replace("%{", "").replace("%}", "").rstrip()
        if tail:
            parts.append((state, tail))
        if parts:
            lines.append(parts)
    return lines


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


def svg(name: str, lines: list[list[tuple[str, str]]]) -> str:
    body = []
    for i, line in enumerate(lines):
        tspans = "".join(f'<tspan fill="{fill}">{html.escape(text)}</tspan>' for fill, text in line)
        body.append(f'  <text x="24" y="{42 + i * 30}">{tspans}</text>')
    body = "\n".join(body)
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
