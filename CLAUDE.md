# CLAUDE.md

## Never run the CI installer commands locally

The workflows in `.github/workflows/` install the Chainloop CLI with:

```
curl -sfL https://api.app.chainloop.dev/cli/install.sh | bash -s
```

That line belongs to the GitHub Actions runners. **Do not execute it, or any
other `curl … | bash` / `curl … | sh` pipeline, in this repo.** The CLI is
already installed on this machine; if it were missing, ask rather than piping a
remote script into a shell.

The same goes for the other commands quoted inside these workflows —
`chainloop attestation init/add/push/reset`, `chainloop project version update`,
`chainloop apply` — which write to the live Chainloop org and to project
versions. Read them, edit them, reason about them, but let CI run them.

## Editing files whose contents look like commands

Because the workflow files *contain* the installer line above, writing them with
a shell heredoc (`cat > file <<'YAML' … YAML`) makes the file body scan as a
command and trips the guard on forbidden bash patterns. Use the `Write` and
`Edit` tools for anything under `.github/workflows/`, not shell redirection.
