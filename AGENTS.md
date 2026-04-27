# AGENTS.md

> A short map for any AI coding agent working in this repo. Treat this as a
> table of contents, not an encyclopedia. The full system of record lives in
> [`docs/`](docs/) — this file just tells you how to get there.

Last reviewed: 2026-04-27.

## What this repo is

A small Jekyll personal blog deployed via GitHub Pages. The whole site is
intentionally low-surface-area: a handful of layouts, one stylesheet, and
Markdown posts.

- Build: `bundle exec jekyll serve` (see [`docs/RELIABILITY.md`](docs/RELIABILITY.md))
- Format: Prettier 3 via the pre-commit hook in `.githooks/pre-commit`
- Docs harness: this file + [`ARCHITECTURE.md`](ARCHITECTURE.md) + [`docs/`](docs/)

## How to navigate (start here)

If you're about to make a change, find your "kind" of change below and follow
the link. Don't read everything in `docs/` up front.

| You're touching…                                                                                        | Go read first                                                                                                       |
| ------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------- |
| A layout / `_includes` / `404.html`                                                                     | [`docs/DESIGN.md`](docs/DESIGN.md), [`docs/product-specs/`](docs/product-specs/)                                    |
| `assets/css/style.scss`                                                                                 | [`docs/DESIGN.md`](docs/DESIGN.md)                                                                                  |
| A post under `_posts/`                                                                                  | [`docs/CONTENT.md`](docs/CONTENT.md)                                                                                |
| `_config.yml`, `Gemfile`, build setup                                                                   | [`docs/RELIABILITY.md`](docs/RELIABILITY.md)                                                                        |
| `.githooks/`, `.prettier*`                                                                              | [`docs/RELIABILITY.md`](docs/RELIABILITY.md) and the rules in `.cursor/rules/`                                      |
| `<head>` SEO, `robots.txt`, `llms.txt`, sitemap, `hreflang`                                             | [`docs/product-specs/seo.md`](docs/product-specs/seo.md)                                                            |
| The agent harness itself (`AGENTS.md`, `CLAUDE.md`, `.cursor/`, `.codex/`, `.claude/`, `scripts/docs/`) | [`docs/design-docs/core-beliefs.md`](docs/design-docs/core-beliefs.md)                                              |
| Anything ambiguous or new                                                                               | [`docs/PLANS.md`](docs/PLANS.md) and create an exec-plan under [`docs/exec-plans/active/`](docs/exec-plans/active/) |

## Core operating principles (read once, then apply)

These are non-negotiable. Full reasoning in
[`docs/design-docs/core-beliefs.md`](docs/design-docs/core-beliefs.md).

1. **The repo is the system of record.** If a decision isn't in this repo, it
   doesn't exist. Promote useful chat / commit-message context into `docs/`.
2. **Edit code → update docs in the same change.** The docs harness will
   remind you. If a doc is wrong, fix it; don't work around it.
3. **Prefer small, additive changes.** Pull requests / commits should each be
   a single coherent unit (1 layout, 1 post, 1 spec, etc.).
4. **Never bypass the pre-commit hook.** Prettier-clean diffs only. See
   [`docs/RELIABILITY.md`](docs/RELIABILITY.md) for the full toolchain.
5. **Don't touch generated paths.** `_site/`, `.jekyll-cache/`, `vendor/`,
   `_layouts/` (Liquid), and `_config.yml` are off-limits to Prettier and to
   reformatting agents. See `.prettierignore` and the cursor rules.

## The doc tree (one screen)

```
AGENTS.md            (this file)
ARCHITECTURE.md      Top-level domains, layers, allowed dependencies
CLAUDE.md            Pointer for Claude Code (it reads this by default)
docs/
├── README.md            Index of docs/
├── design-docs/         Why this repo is shaped the way it is
│   ├── index.md
│   └── core-beliefs.md  Agent-first operating principles for this repo
├── exec-plans/          Plans treated as first-class artifacts
│   ├── README.md        Format + lifecycle
│   ├── active/          In-flight plans (one file each)
│   ├── completed/       Archived plans
│   └── tech-debt-tracker.md
├── product-specs/       What each user-visible feature is supposed to do
│   ├── index.md
│   ├── internationalization.md
│   ├── sidebar-navigation.md
│   ├── post-layout.md
│   └── seo.md
├── references/          External docs cached as llms.txt for agent context
│   ├── jekyll-llms.txt
│   └── prettier-llms.txt
├── generated/           Auto-generated docs (currently empty placeholder)
│   └── README.md
├── CONTENT.md           Voice, tone, frontmatter, post conventions
├── DESIGN.md            Design tokens, layout system, accessibility
├── PLANS.md             Short-term roadmap and currently-active goals
├── QUALITY_SCORE.md     Per-domain quality grades and known gaps
├── RELIABILITY.md       Build, deploy, formatter, hooks
└── SECURITY.md          Threat model and the few rules that apply here
```

## Workflow expectations

- When you finish a code change, the runtime hooks (Cursor / Codex / Claude
  Code) will inject a docs reminder via `scripts/docs-check.sh`. Listen to it.
- Run `bash scripts/docs-check.sh --mode lint` locally before opening a PR.
  The same script runs in CI; failing here means the docs are out of sync
  with code.
- For a non-trivial change (more than one file or one concept), open an
  exec-plan under `docs/exec-plans/active/`. See
  [`docs/exec-plans/README.md`](docs/exec-plans/README.md) for the format.
- For a trivial change (typo, single CSS tweak, single post), an exec-plan is
  not required.

## When in doubt

Promote the question into `docs/`, not into a chat. If you discover that a
rule is missing or wrong, the fix is to edit the relevant doc in the same
commit as the code, not to add a one-off comment.
