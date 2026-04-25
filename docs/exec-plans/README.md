# Exec plans

Plans are first-class artifacts. Anything beyond a one-line change should
have a plan that lives in this directory.

Last reviewed: 2026-04-25.

## Layout

- [`active/`](active/) — one Markdown file per in-flight plan. Files here are
  expected to change as the plan progresses.
- [`completed/`](completed/) — archived plans. Move a file here when the work
  is done; do not delete it. Past plans are an audit trail for both humans
  and future agents.
- [`tech-debt-tracker.md`](tech-debt-tracker.md) — single growing list of
  known shortcuts, with the price tag for each.

## When to write one

| Change shape                                                         | Plan?                         |
| -------------------------------------------------------------------- | ----------------------------- |
| Typo, prose tweak, single CSS variable                               | No.                           |
| New post under `_posts/`                                             | No. The post is the artifact. |
| New layout, new spec, new design token set                           | Yes.                          |
| Anything touching `.cursor/`, `.codex/`, `.claude/`, `scripts/docs/` | Yes.                          |
| Anything that requires reading more than one facet doc               | Yes.                          |

## Filename + format

- File: `active/<YYYY-MM-DD>-<kebab-slug>.md`.
- Front matter (plain Markdown, no Jekyll frontmatter):

  ```
  # <One-line title>

  Status: in-progress | blocked | abandoned | shipped
  Owner: <agent-or-human>
  Opened: YYYY-MM-DD
  Updated: YYYY-MM-DD
  Related: <links to specs / facets / other plans>
  ```

- Sections:
  1. **Goal.** What "done" looks like, in two sentences.
  2. **Approach.** Bullet list of the steps. Keep it short; refine as you
     learn.
  3. **Open questions.** Things you are explicitly waiting on or unsure of.
  4. **Decision log.** Append-only list of `YYYY-MM-DD: <decision>`.

A good plan fits on one screen. If it doesn't, split it.

## Lifecycle

1. Open the plan in `active/` _before_ you start editing code.
2. As you work, append to **Decision log** rather than rewriting earlier
   sections.
3. When done, change `Status` to `shipped`, add a one-line outcome at the
   top, and `git mv` the file into `completed/`.
4. If the plan is abandoned, change `Status` to `abandoned`, write one
   sentence on why, and move it to `completed/` anyway.

## Why all this for a personal blog?

The harness exists to scale. The cost of writing a one-screen plan is
seconds; the value is that any agent picking up the work later — including
yourself, six months from now — can reproduce your reasoning.
