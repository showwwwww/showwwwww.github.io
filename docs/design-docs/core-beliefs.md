# Core beliefs (agent-first operating principles)

The repo is small, but it is operated agent-first: most edits will arrive via
Cursor, Codex, or Claude Code. These are the rules the harness is built on.

Last reviewed: 2026-04-25.

## 1. The repo is the system of record

If a fact is not in the repo, it is not real to the agent. Slack threads,
chat windows, and human memory don't survive context resets. Promote useful
context into:

- `docs/` for durable knowledge.
- `docs/exec-plans/active/` for in-flight work.
- Inline code comments **only** for non-obvious intent that cannot be moved.

Corollary: if a doc is wrong, fix the doc; don't paper over it in code.

## 2. AGENTS.md is a map, not a manual

The 100-line cap on `AGENTS.md` is intentional. Once it grows past that, the
right move is to push detail into `docs/` and link to it. A monolithic
`AGENTS.md` rots silently; a small one is easy to keep true.

## 3. Edit code → update docs in the same change

Every per-runtime hook (`scripts/docs-check.sh --mode hook ...`) reminds the
agent of this. The reminder is non-blocking by default; if you ignore it once,
the `Stop` hook will repeat it once with a `block`-style continuation. After
that, it gets out of your way (loop cap = 1).

This is enforceable mechanically:

- The hook compares the set of changed code files against the set of changed
  doc files for the current turn / working tree.
- If code changed but no relevant doc was touched, you get a reminder
  pointing at the specific docs that own the changed paths.
- The mapping lives in `scripts/docs-check.sh` (`code_to_docs`), and is also
  encoded as the file map in `ARCHITECTURE.md`. The two must stay in sync.

## 4. Mechanical enforcement over taste

Every rule in this repo is either:

- **Enforced** — by Prettier, the pre-commit hook, the doc-check linter, or
  Jekyll's own build. If the tool doesn't catch it, it isn't a rule yet.
- **Documented** — as a one-liner in the relevant facet doc, with the
  expectation that the next person to feel its absence will promote it to
  enforced.

We do not have rules that exist only as norms. They turn into a graveyard.

## 5. Plans are first-class artifacts

For anything beyond a trivial change, write an `exec-plans/active/<slug>.md`
file _before_ editing code. A plan should fit on one screen and should make
the change reviewable by a human in under a minute. When done, move it to
`exec-plans/completed/` with a one-line outcome.

The harness does not currently enforce this — it's a discipline, not a
linter check. If we find ourselves repeatedly skipping it, the response is to
encode it (e.g. block PRs that touch ≥N files without a referenced plan).

## 6. Boring tools, in-repo state

We prefer tools and patterns that are:

- Well-represented in agent training data (Jekyll, Liquid, Prettier, Bash,
  jq, plain shell).
- Configurable from in-repo files (no dashboards-as-source-of-truth).
- Composable enough that the agent can inspect and modify their config
  directly.

This rules out, e.g., a JS bundler with magic plugins, or a CMS that owns
content out-of-tree.

## 7. The harness owns itself

The docs harness (this file, `AGENTS.md`, `ARCHITECTURE.md`, `docs/`,
`scripts/docs/`, and the per-runtime hook configs in `.cursor/`, `.codex/`,
`.claude/`) is itself code. It follows the same rules:

- Changes to it must update this doc in the same commit.
- Adding a new runtime requires: a new hook config, a new wrapper that calls
  `scripts/docs-check.sh --mode hook --runtime <name> --event <event>`, and
  a row in the table inside [`RELIABILITY.md`](../RELIABILITY.md#agent-runtime-hooks).
- The hook script's per-runtime emit functions are the contract; if a
  runtime changes its hook output schema upstream, only the emit function
  for that runtime needs to change.

## 8. Fail open, but be loud

The hook scripts fail open: if `jq` is missing, if the script can't tell
what changed, if anything goes wrong, the script exits 0 and prints a
diagnostic to stderr. This keeps the agent unblocked. The lint mode
(`--mode lint`) is the strict counterpart; it is allowed to fail loudly and
should be wired into CI when CI exists.

## What we're still figuring out

- We do not yet have a CI workflow that runs `--mode lint`. Adding one is
  tracked in [`exec-plans/tech-debt-tracker.md`](../exec-plans/tech-debt-tracker.md).
- We do not yet have a "doc-gardening" agent that opens PRs against stale
  docs on its own. The current human-in-the-loop reminder is the substitute.
- The runtime hook reminders are advisory text. We have not yet measured how
  often agents act on them.
