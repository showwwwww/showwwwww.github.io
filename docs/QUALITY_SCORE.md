# QUALITY_SCORE.md

> Rough grades per domain so we know where to invest harness work next.
> Update during regular reviews; don't tweak on every commit.

Last reviewed: 2026-04-25.

## Grading scale

- **A** — Documented, mechanically enforced, and currently true.
- **B** — Documented and currently true; enforcement is manual.
- **C** — Partially documented, no enforcement, easy to drift.
- **D** — Effectively undocumented; living tribal knowledge.
- **F** — Known broken / wrong.

A "current" grade is meant to reflect the state on the **Last reviewed**
date above; a stale grade is itself a signal.

## Scores

| Domain                                                     | Grade | Notes                                                                                                                                                                         |
| ---------------------------------------------------------- | ----- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Build (Jekyll, Gemfile, GitHub Pages compatibility)        | B     | Pinned in `Gemfile`; no CI yet to enforce that the lockfile builds clean. See [`RELIABILITY.md`](RELIABILITY.md) and the tech-debt tracker.                                   |
| Formatting (Prettier 3 + pre-commit hook)                  | A     | Hook script + `.prettierrc.json` + `.prettierignore` + cursor rules. Enforced per commit.                                                                                     |
| Site shell (`_layouts/default.html`, `_layouts/home.html`) | B     | Spec'd in [`product-specs/sidebar-navigation.md`](product-specs/sidebar-navigation.md). Behavior verified by hand; no automated render tests.                                 |
| Post / page layouts (`post.html`, `page.html`, `404.html`) | B     | Spec'd in [`product-specs/post-layout.md`](product-specs/post-layout.md). Same caveats as above.                                                                              |
| Theme (`assets/css/style.scss`)                            | B     | Tokens documented in [`DESIGN.md`](DESIGN.md). No visual regression check.                                                                                                    |
| Content / posts (`_posts/`, `*.markdown`)                  | C     | Conventions in [`CONTENT.md`](CONTENT.md) but only one real post exists yet, so the conventions are mostly aspirational.                                                      |
| Reliability of build + deploy                              | C     | GitHub Pages handles the deploy and we trust it; we have no monitoring or rollback story.                                                                                     |
| Security                                                   | A     | Surface area is "static HTML on GitHub Pages." See [`SECURITY.md`](SECURITY.md).                                                                                              |
| Agent harness itself                                       | B     | Documented in [`design-docs/core-beliefs.md`](design-docs/core-beliefs.md), with a working `scripts/docs-check.sh` and per-runtime hooks. Lint mode is not yet wired into CI. |

## How to use this table

- When opening a non-trivial PR, check the row for the domain you're
  touching. If the grade implies "no enforcement," prefer to add a check
  rather than just adding more docs.
- When a row drops a grade, add a corresponding row to
  [`exec-plans/tech-debt-tracker.md`](exec-plans/tech-debt-tracker.md) so
  the cost of leaving it isn't invisible.

## Out of scope

- A numerical score or weighted average. The grades are coarse on purpose
  — anything finer would be noise at this scale.
