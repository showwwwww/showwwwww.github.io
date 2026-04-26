# RELIABILITY.md — build, deploy, formatter, hooks

Owns: `Gemfile`, `Gemfile.lock`, `_config.yml`, `.githooks/`, `.prettier*`,
`.cursor/`, `.codex/`, `.claude/`, and `scripts/docs/`.

Last reviewed: 2026-04-25.

## Build

- Jekyll 4.3.x, pinned in `Gemfile`.
- A handful of transitive deps are also pinned (`public_suffix < 6`, `csv`,
  `ffi < 1.17`, `jekyll-sass-converter ~> 2.0`) so `bundle install` works
  on Ruby 2.6.x as well as on GitHub Pages CI.
- Local commands:

  ```
  bundle install
  bundle exec jekyll serve   # dev server with reload
  bundle exec jekyll build   # one-shot build into _site/
  bundle exec jekyll clean   # nuke _site/ and .jekyll-cache/
  ```

- `_config.yml` changes require a server restart (Jekyll does not watch
  the config file). All other changes hot-reload.
- `_config.yml` keeps build/feed metadata such as `title` and `description`.
  Functional UI copy is managed centrally in `_data/i18n.yml`; content copy
  remains in content/frontmatter/config until a future content source replaces
  it.
- `_config.yml` explicitly excludes `docs/`, `AGENTS.md`, `ARCHITECTURE.md`,
  and `CLAUDE.md` from Jekyll processing. GitHub Pages may render Markdown
  without front matter, so internal agent/docs Markdown must stay out of the
  public route graph.

## Deploy

- GitHub Pages builds and serves the site automatically from the default
  branch.
- We do **not** vendor a `Gemfile.lock` for Pages because Pages uses its
  own pinned bundle. The local `Gemfile.lock` is gitignored.
- There is currently no health check or canary. If a build fails on Pages,
  the previous successful version stays live; we find out about failures
  via the GitHub email notification.

## Formatter

- Prettier 3 via `npx --yes prettier@^3` (no committed `package.json`).
- Config: `.prettierrc.json`. Ignores: `.prettierignore`. Both are Prettier
  3 native; do not introduce Prettier 2 idioms.
- Pre-commit hook lives at `.githooks/pre-commit`. Activate per clone with:

  ```
  git config core.hooksPath .githooks
  ```

- Hook behavior is documented in `.cursor/rules/commit-hook.mdc`. The hook
  fails open if `npx` is missing.

## Doc-check (the harness)

- Single entry point: `scripts/docs-check.sh`.
- Modes:

  ```
  bash scripts/docs-check.sh --mode lint
      Verify the docs system. Strict; intended for CI and manual runs.
      Returns non-zero when something is wrong.

  bash scripts/docs-check.sh --mode hook \
      --runtime <cursor|codex|claude> \
      --event <post-edit|stop>
      Read the runtime's hook payload on stdin and emit JSON shaped for
      that runtime. Always exits 0; failures degrade to a stderr warning.
  ```

- Lint checks (current):
  - Required files exist (`AGENTS.md`, `ARCHITECTURE.md`, `CLAUDE.md`,
    every file referenced from the table in `docs/README.md`).
  - Internal Markdown is excluded from Jekyll routes. Only `index.markdown`
    and Markdown under `_posts/` should publish as content.
  - `AGENTS.md` is at most 150 lines.
  - All relative Markdown links inside `AGENTS.md`, `ARCHITECTURE.md`, and
    `docs/**/*.md` resolve to existing files.
  - The mapping table in `code_to_docs` (inside `scripts/docs-check.sh`)
    points only at files that exist.

- Hook behavior:
  - Computes the changed-file set via `git status --porcelain` plus, when
    available, `git diff --name-only HEAD@{1} HEAD` to cover the most
    recent commit.
  - Checks the Markdown route boundary on every post-edit / stop event and
    reminds the agent if internal Markdown could become a public Jekyll page.
  - Maps each changed source file to the doc(s) that own it.
  - Emits a reminder only if the agent edited code without touching any of
    the relevant docs.
  - For `Stop` events on Codex and Claude Code, the script honors
    `stop_hook_active` so it never fires twice in the same turn. Cursor
    `stop` stores a checksum under `.git/` and suppresses the same reminder
    for the same `HEAD`, so an ignored reminder cannot loop forever while
    the working tree is unchanged.

## Agent runtime hooks

| Runtime     | Config file                                                                               | Wrapper scripts                                                     |
| ----------- | ----------------------------------------------------------------------------------------- | ------------------------------------------------------------------- |
| Cursor      | `.cursor/hooks.json`                                                                      | `.cursor/hooks/docs-after-edit.sh`, `.cursor/hooks/docs-on-stop.sh` |
| Codex CLI   | `.codex/hooks.json` (with the `codex_hooks` feature flag enabled in `.codex/config.toml`) | `.codex/hooks/docs-after-edit.sh`, `.codex/hooks/docs-on-stop.sh`   |
| Claude Code | `.claude/settings.json`                                                                   | `.claude/hooks/docs-after-edit.sh`, `.claude/hooks/docs-on-stop.sh` |

Each wrapper is a thin shim that resolves the repo root via `git
rev-parse --show-toplevel` and then delegates to `scripts/docs-check.sh
--mode hook --runtime ... --event ...`. The shims exist so per-runtime
config files can use stable paths even if the shared script's flag set
changes later.

To add a new runtime: write a new wrapper, add a new emit function in
`scripts/docs-check.sh`, add a row to this table, and add a row to the
table in [`design-docs/core-beliefs.md`](design-docs/core-beliefs.md)
section "The harness owns itself."

## What can break (and what to do)

- **Prettier hook missing on a clone.** Symptom: a commit lands with bad
  formatting. Fix: `git config core.hooksPath .githooks`.
- **`jq` not installed locally.** Symptom: doc-check hooks emit no JSON
  (fail open). Fix: install `jq` (it ships with most macOS dev setups via
  Homebrew). The hooks remain advisory; nothing breaks.
- **GitHub Pages build failure.** Symptom: email from GitHub. Triage:
  reproduce locally with `bundle exec jekyll build`; check the Gemfile
  pins haven't drifted from Pages's bundle.
- **Stale docs.** Symptom: `scripts/docs-check.sh --mode lint` warns about
  a missing target or oversized `AGENTS.md`. Fix: in the same commit as
  whatever caused the drift.

## Out of scope

- Performance budgets. The site is static and tiny.
- Internationalization of the build pipeline.
- Multi-environment deploy (staging vs. prod). One env: GitHub Pages.
