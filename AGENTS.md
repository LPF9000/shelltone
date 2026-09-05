# Local contribution rules

- Create a descriptive feature branch before making changes.
- Open a pull request for every completed change.
- Use a normal branch and pull request for standalone work based on `main`. Use a stacked PR only when a new branch deliberately depends on an unmerged branch or pull request below it. Do not create a stack merely because a branch exists; create one only when planning dependent review layers before the lower layer merges.
- Use the LPF9000 account identity for commits and review activity.
- Before any `gh` command, verify that the active GitHub CLI account is `LPF9000`; do not use `gh` if another account is active.
- Keep commit messages, pull-request text, and comments limited to observable product behavior.
- Do not include tool, assistant, model, or request-provenance language in repository content or review activity.
