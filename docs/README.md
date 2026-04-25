# docs/

> The system of record for this repo. `AGENTS.md` is the table of contents;
> this directory holds the chapters.

Last reviewed: 2026-04-25.

## Map

| Folder / file                          | What it is                                                                                                   |
| -------------------------------------- | ------------------------------------------------------------------------------------------------------------ |
| [`design-docs/`](design-docs/)         | Why the repo is shaped the way it is. The `core-beliefs.md` file holds the agent-first operating principles. |
| [`exec-plans/`](exec-plans/)           | Active and completed plans for non-trivial work, plus the tech-debt tracker.                                 |
| [`product-specs/`](product-specs/)     | One file per user-visible feature, including sidebar, post layout, and internationalization behavior.        |
| [`references/`](references/)           | External docs cached locally as `*-llms.txt` so agents have stable context (Jekyll, Prettier).               |
| [`generated/`](generated/)             | Reserved for auto-generated docs (e.g. site map, post index). Currently empty.                               |
| [`CONTENT.md`](CONTENT.md)             | Voice, tone, frontmatter, post conventions, and the boundary between content and functional text.            |
| [`DESIGN.md`](DESIGN.md)               | Design tokens, layout rules, accessibility, dark mode.                                                       |
| [`PLANS.md`](PLANS.md)                 | Short-term roadmap and currently-active goals.                                                               |
| [`QUALITY_SCORE.md`](QUALITY_SCORE.md) | Per-domain quality grades and known gaps.                                                                    |
| [`RELIABILITY.md`](RELIABILITY.md)     | Build, deploy, formatter, hooks.                                                                             |
| [`SECURITY.md`](SECURITY.md)           | Threat model and the few rules that apply here.                                                              |

## Conventions

- Every Markdown file under `docs/` ends with a single trailing newline,
  Prettier-clean (see `.cursor/rules/prettier-formatting.mdc`).
- Top-level facet docs (`CONTENT.md`, `DESIGN.md`, etc.) and `AGENTS.md` /
  `ARCHITECTURE.md` carry a `Last reviewed: YYYY-MM-DD` line near the top.
  `scripts/docs-check.sh --mode lint` warns when this date drifts more than
  90 days behind the most recent edit to its owned code paths.
- Cross-links use relative Markdown links (`[label](relative/path.md)`). The
  doc-check script verifies these resolve.
- No images in this directory unless they're embedded directly. We don't
  store binary assets next to docs.

## How to add a new doc

1. Decide whether it's a long-lived facet (top-level), a feature spec
   (`product-specs/`), a one-shot plan (`exec-plans/active/`), or background
   on a decision (`design-docs/`).
2. Add the file using the conventions above.
3. Update this `README.md` and (if it's a facet) `AGENTS.md`'s table.
4. Run `bash scripts/docs-check.sh --mode lint` before committing.

## How to retire a doc

- Plans: move from `exec-plans/active/` to `exec-plans/completed/` and add a
  one-line outcome at the top of the file.
- Specs: if a feature is removed, delete the spec and add a row to
  `exec-plans/tech-debt-tracker.md` if anything residual needs cleaning up.
- Facets: don't delete. If a facet becomes irrelevant (e.g. SECURITY.md for a
  static blog), shrink it to a one-paragraph "no current threats" note and
  keep the file so cross-links don't rot.
