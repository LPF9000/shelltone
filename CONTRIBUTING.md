# Contributing

Thanks for improving Shelltone.

Create a descriptive feature branch from `main`, keep each pull request focused on one observable behavior, and use the LPF9000 account identity for commits and review activity. Do not include internal tooling or request history in repository text.

Run the checks before opening a pull request:

```sh
./tests/check.bash
./tests/check.zsh
python3 tests/test-runtime.py -v
./tests/check-compat.sh
./tests/check-terminal.sh
./tests/check-visual.sh
./bin/shelltone-benchmark
```

Changes to a palette or layout should include compact and two-line behavior. Changes to prompt rendering should include a deterministic visual snapshot update and a note explaining any intentional spacing or color change. Test with an ordinary monospace font as well as a patched font when glyph alignment is relevant.

For integration changes, test plain Zsh and at least one framework loading path. Shelltone should be sourced after a framework has loaded its plugins and should be the only prompt engine that owns the final prompt variables.
