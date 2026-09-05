#!/usr/bin/env python3
"""Regression checks for prompt data and real interactive shell lifecycles."""
import fcntl
import os
from pathlib import Path
import pty
import select
import shlex
import struct
import subprocess
import tempfile
import termios
import time
import unittest

ROOT = Path(__file__).resolve().parents[1]


class Terminal:
    def __init__(self, shell):
        self.master, slave = pty.openpty()
        fcntl.ioctl(slave, termios.TIOCSWINSZ, struct.pack("HHHH", 30, 160, 0, 0))
        args = [shell, "-f", "-i"] if shell == "zsh" else [shell, "--noprofile", "--norc", "-i"]
        self.process = subprocess.Popen(args, stdin=slave, stdout=slave, stderr=slave,
                                        env={**os.environ, "TERM": "xterm-256color"})
        os.close(slave)
        self.output = b""

    def send(self, text):
        os.write(self.master, text.encode() + b"\n")

    def until(self, marker, timeout=5):
        deadline = time.monotonic() + timeout
        while marker not in self.output:
            remaining = deadline - time.monotonic()
            if remaining <= 0:
                raise AssertionError(f"Missing {marker!r}: {self.output[-3000:]!r}")
            if select.select([self.master], [], [], remaining)[0]:
                self.output += os.read(self.master, 65536)
        before, self.output = self.output.split(marker, 1)
        return before

    def close(self):
        self.send('exit')
        try:
            self.process.wait(timeout=2)
        except subprocess.TimeoutExpired:
            self.process.kill()
            self.process.wait(timeout=2)
        finally:
            os.close(self.master)


class Runtime(unittest.TestCase):
    def setUp(self):
        self.scratch = tempfile.TemporaryDirectory(prefix="shelltone-runtime-")
        self.repo = Path(self.scratch.name)
        self.git("init", "-q", "-b", "main")
        self.git("config", "user.name", "LPF9000")
        self.git("config", "user.email", "56581520+LPF9000@users.noreply.github.com")
        (self.repo / "tracked").write_text("base\n")
        self.git("add", ".")
        self.git("commit", "-qm", "Add tracked file")

    def tearDown(self):
        self.scratch.cleanup()

    def git(self, *args, check=True):
        return subprocess.run(["git", "-C", str(self.repo), *args], check=check,
                              stdout=subprocess.PIPE, stderr=subprocess.PIPE)

    def shell(self, shell, code):
        args = [shell, "-f", "-c"] if shell == "zsh" else [shell, "--noprofile", "--norc", "-c"]
        setup = f'SHELLTONE_CONFIG=/dev/null; source {shlex.quote(str(ROOT / ("shelltone." + shell)))}; '
        result = subprocess.run(args + [setup + code], cwd=self.repo, text=True,
                                stdout=subprocess.PIPE, stderr=subprocess.PIPE, timeout=10)
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        return result.stdout

    def test_conflicts_and_operations(self):
        self.git("checkout", "-qb", "side")
        (self.repo / "tracked").write_text("side\n")
        self.git("commit", "-qam", "Change tracked text")
        self.git("checkout", "-q", "main")
        (self.repo / "tracked").write_text("main\n")
        self.git("commit", "-qam", "Update tracked text")
        self.git("merge", "side", check=False)
        for shell in ("bash", "zsh"):
            self.shell(shell, '_shelltone_git_collect; [[ $_stg_conflicted == 1 && $_stg_staged == 0 && $_stg_changed == 0 && $_stg_action == merge ]]')

    def test_detached_worktree_and_literal_branch(self):
        self.git("checkout", "-qb", "literal%F{red}")
        self.shell("zsh", '_shelltone_git; [[ ${_shelltone_git_parts[3]} == *"literal%%F{red}" ]]')
        worktree = self.repo / "linked"
        self.git("worktree", "add", "--detach", str(worktree), "HEAD")
        for shell in ("bash", "zsh"):
            self.shell(shell, f'cd {shlex.quote(str(worktree))}; _shelltone_git_collect; [[ $_stg_branch == @* && $_stg_action == "" ]]')

    def test_preset_git_vocabulary(self):
        (self.repo / "tracked").write_text("changed\n")
        (self.repo / "new").write_text("new\n")
        for shell in ("bash", "zsh"):
            self.shell(shell, '_shelltone_git_collect; [[ $_stg_changed == 1 && $_stg_untracked == 1 ]] || exit 1; SHELLTONE_GIT_DETAIL=false; _shelltone_git_collect; (( _stg_changed + _stg_untracked == 1 ))')
            command = '_shelltone_bash_git; result=$SHELLTONE_BASH_GIT' if shell == 'bash' else '_shelltone_git; result=${(j: :)_shelltone_git_parts}'
            self.shell(shell, 'SHELLTONE_GIT_LABEL_STYLE=purity; SHELLTONE_GIT_PREFIX_FG=6; SHELLTONE_GIT_COLON_FG=7; SHELLTONE_GIT_BRANCH_FG=3; ' + command + '; [[ $result == *✶* && $result == *✩* && $result != *"!1"* ]]')

    def test_path_modes_and_duration(self):
        for shell in ("bash", "zsh"):
            self.shell(shell, 'PWD=/projects/long-parent/component; COLUMNS=80; SHELLTONE_PATH_MODE=basename; _shelltone_path; [[ $REPLY == component ]] || exit 1; SHELLTONE_PATH_MODE=full; _shelltone_path; [[ $REPLY == "$PWD" ]] || exit 1; SHELLTONE_PATH_MODE=auto; SHELLTONE_MAX_DIR_LENGTH=20; _shelltone_path; [[ $REPLY == /p/l/component ]] || exit 1; _shelltone_duration 3661; [[ $REPLY == "1h 1m 1s" ]]')

    def test_zsh_layout_highlighting_and_width(self):
        self.shell('zsh', 'COLUMNS=160; SHELLTONE_TWO_LINES=false; _shelltone_set_prompt; [[ -n $RPROMPT ]] || exit 1; SHELLTONE_TWO_LINES=true; _shelltone_set_prompt; [[ -z $RPROMPT ]] || exit 1; region_highlight=("0 2 fg=red" "0 3 fg=blue memo=shelltone"); SHELLTONE_SYNTAX_HIGHLIGHT=false; _shelltone_syntax_highlight; [[ ${#region_highlight} == 1 ]] || exit 1; _shelltone_display_width "漢字"; [[ $REPLY == 4 ]]')

    def test_bash_reload_hooks_and_compact(self):
        self.shell('bash', f'_shelltone_previous_hooks=(\'seen=$?\' \'second=$?\'); source {shlex.quote(str(ROOT / "shelltone.bash"))}; SHELLTONE_TWO_LINES=false; SHELLTONE_ADD_NEWLINE=false; (exit 7); _shelltone_bash_precmd; [[ $seen == 7 && $second == 7 && $SHELLTONE_BASH_TOP == *"✘ 7"* && $PS1 != *"\\n"* ]]')

    def test_interactive_reload_and_duration(self):
        for shell in ('bash', 'zsh'):
            with self.subTest(shell=shell):
                terminal = Terminal(shell)
                try:
                    path = shlex.quote(str(ROOT / ('shelltone.' + shell)))
                    terminal.send(f'SHELLTONE_CONFIG=/dev/null; SHELLTONE_GIT_ASYNC=false; source {path}; source {path}; SHELLTONE_SHOW_TIME=false; SHELLTONE_DURATION_THRESHOLD=1; printf "\\n%s%s\\n" REA DY')
                    terminal.until(b'READY\r\n')
                    terminal.send('sleep 1.1')
                    terminal.until(b'1s', timeout=5)
                    terminal.send('printf "\\n%s%s\\n" AL IVE')
                    terminal.until(b'ALIVE\r\n')
                finally:
                    terminal.close()

    def test_zsh_async_and_transient(self):
        terminal = Terminal('zsh')
        try:
            path = shlex.quote(str(ROOT / 'shelltone.zsh'))
            terminal.send(f'SHELLTONE_CONFIG=/dev/null; SHELLTONE_GIT_ASYNC=false; source {path}; SHELLTONE_SHOW_TIME=false; SHELLTONE_TRANSIENT=true; printf "\\n%s%s\\n" REA DY')
            terminal.until(b'READY\r\n')
            terminal.send('_shelltone_git_collect() { sleep 1; _shelltone_git_clear; _stg_branch=LA\'TE\'; }; SHELLTONE_GIT_ASYNC=true; printf "\\n%s%s\\n" FA ST')
            terminal.until(b'FAST\r\n', timeout=2)
            terminal.until(b'LATE', timeout=4)
            terminal.send('printf "\\n%s%s\\n" AL IVE')
            terminal.until(b'ALIVE\r\n')
        finally:
            terminal.close()


if __name__ == '__main__':
    unittest.main()
