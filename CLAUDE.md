# CLAUDE.md

> Thin pointer for Claude Code. The actual operating manual is shared with
> every other agent (Cursor, Codex, …) and lives in [`AGENTS.md`](AGENTS.md).
> Read that first.

Last reviewed: 2026-04-25.

## In one paragraph

This repo is a Jekyll personal blog with a small docs harness on top. The
single source of truth for "how things work here" is the [`docs/`](docs/)
directory, indexed from [`AGENTS.md`](AGENTS.md). When you change code,
update the relevant doc(s) in the same change — the harness will remind
you via [`scripts/docs-check.sh`](scripts/docs-check.sh).

## Hooks you'll see

The project ships per-runtime hooks for Cursor, Codex, and Claude Code.
For Claude Code specifically, the configuration lives in
[`.claude/settings.json`](.claude/settings.json) and the wrappers in
[`.claude/hooks/`](.claude/hooks/). Both fire `scripts/docs-check.sh`:

- `PostToolUse` (matcher `Edit|Write|MultiEdit`) — non-blocking reminder
  injected into your context if you edited code without touching the
  doc(s) that own those code paths.
- `Stop` — one-shot reminder that asks for a follow-up turn if a docs
  update still seems missing. Bounded by `stop_hook_active` so it never
  loops.

If `jq` isn't on `$PATH`, the hooks fail open (silently). Install `jq`
locally to get the reminders.

## Where to look first

- Map: [`AGENTS.md`](AGENTS.md)
- Floor plan: [`ARCHITECTURE.md`](ARCHITECTURE.md)
- Why-it's-shaped-this-way: [`docs/design-docs/core-beliefs.md`](docs/design-docs/core-beliefs.md)
- Build / formatter / hooks: [`docs/RELIABILITY.md`](docs/RELIABILITY.md)
- The harness contract: [`scripts/docs-check.sh`](scripts/docs-check.sh)

## Don't

- Don't expand this file into a second source of truth. If a rule applies
  to all agents, put it in `AGENTS.md` or the relevant `docs/` page; if
  it's Claude-Code-specific, put it here.
- Don't bypass the pre-commit hook (`.githooks/pre-commit`). It is the
  formatter contract for the repo.
- Don't edit `_layouts/`, `_includes/`, `404.html`, or `_config.yml` with
  Prettier — they're in `.prettierignore` for a reason. Hand-edit Liquid.
