# PLANS.md — short-term roadmap

> What's actively in flight, what's queued, and what's deferred. This file
> is the human-readable counterpart to [`exec-plans/`](exec-plans/) — keep
> it short.

Last reviewed: 2026-04-25.

## Now (in flight)

- Stand up the agent harness: `AGENTS.md`, `ARCHITECTURE.md`, `docs/`,
  `scripts/docs-check.sh`, and per-runtime hooks for Cursor / Codex /
  Claude Code. Tracking via the conversation that produced this commit;
  no exec-plan file because the work is the harness itself.

## Next (queued, no exec-plan yet)

- Wire `scripts/docs-check.sh --mode lint` into a `.github/workflows/`
  workflow so doc drift is caught even when no agent is in the loop. See
  [`exec-plans/tech-debt-tracker.md`](exec-plans/tech-debt-tracker.md).
- Decide what (if anything) to put in [`generated/`](generated/) and write
  the first generator. See [`generated/README.md`](generated/README.md).
- Add structural lints for the rules in `ARCHITECTURE.md` ("no inline
  `<style>`", "no `<script>` in posts").

## Later (idea bin)

- A `_drafts/` workflow that lets agents stage posts without commit noise.
- A small `_includes/` partial set once the second use of any HTML snippet
  appears (rule of three: extract on the third copy, not the second).
- An RSS-only category for harness changelog entries, so subscribers don't
  see them mixed with regular posts.

## Done (recent — older items move to exec-plans/completed/)

- Per-clone Prettier pre-commit hook.
- Custom layouts overriding Minima.
- Sidebar navigation with year-grouped post list and mobile hamburger.

## Conventions for this file

- Move items downward as their status changes (`Now` → `Done`, or stays in
  `Next`/`Later`).
- When something in `Now` grows beyond one line, promote it to an exec-plan
  in `exec-plans/active/` and link to it from here.
- Don't keep "Done" items here forever. After a few months, prune them; the
  audit trail is in `exec-plans/completed/` and `git log`.
