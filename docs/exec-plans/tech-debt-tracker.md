# Tech debt tracker

A single growing list of shortcuts the harness has knowingly taken. Each
entry has a price tag so we can decide when to pay it down.

Last reviewed: 2026-04-25.

## How to use this file

- Append to the table when a change deliberately leaves something undone.
- Pull a row off the table by either fixing the issue (in which case delete
  the row in the same commit) or by writing an exec-plan for it under
  `active/`.
- Don't use this file for "future ideas." Those go in `docs/PLANS.md`.

## Open items

| Item                                                                                                                          | Owner doc                                                          | Cost of leaving it                                                        | Cost of fixing it                                                                               |
| ----------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------ | ------------------------------------------------------------------------- | ----------------------------------------------------------------------------------------------- |
| No CI workflow runs `scripts/docs-check.sh --mode lint`. The harness only catches drift when an agent is in the loop.         | [`../RELIABILITY.md`](../RELIABILITY.md)                           | Doc drift can ship if a human commits via the UI or bypasses local hooks. | One small `.github/workflows/docs.yml` that runs the lint on every PR.                          |
| Layered linting of architectural rules from `ARCHITECTURE.md` is undocumented (e.g. "no inline `<style>` in `_layouts/`").    | [`../../ARCHITECTURE.md`](../../ARCHITECTURE.md)                   | Architectural drift is currently caught only at review time.              | A grep-based check inside `scripts/docs-check.sh --mode lint`.                                  |
| The `code_to_docs` mapping inside `scripts/docs-check.sh` and the file map in `ARCHITECTURE.md` must be kept in sync by hand. | [`../design-docs/core-beliefs.md`](../design-docs/core-beliefs.md) | Easy to forget when adding a new path.                                    | Generate one from the other; or add a lint that compares both.                                  |
| `docs/generated/` is empty. We have not yet decided what (if anything) to auto-generate.                                      | [`../generated/README.md`](../generated/README.md)                 | Low — it's a placeholder.                                                 | Choose one generator (e.g. a post index) and wire it.                                           |
| The runtime hook reminders are advisory text. We have not measured whether agents act on them.                                | [`../design-docs/core-beliefs.md`](../design-docs/core-beliefs.md) | We're flying on intuition.                                                | Add a tiny session-scoped log that records when the reminder fired and what the agent did next. |

## Closed items (for the audit trail)

_None yet._
