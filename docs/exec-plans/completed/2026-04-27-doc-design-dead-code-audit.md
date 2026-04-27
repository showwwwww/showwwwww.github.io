# Doc/design/dead-code audit

Outcome: Shipped. Docs, design contract, and templates are back in sync for
the audited items: localized home hero eyebrow, post-header brand icon,
simplified toolbar classes, and stale plan state cleared from `active/`.

Status: shipped
Owner: Codex
Opened: 2026-04-27
Updated: 2026-04-27
Shipped: 2026-04-27
Related:
[`../../DESIGN.md`](../../DESIGN.md),
[`../../product-specs/sidebar-navigation.md`](../../product-specs/sidebar-navigation.md),
[`../../product-specs/post-layout.md`](../../product-specs/post-layout.md),
[`../../product-specs/internationalization.md`](../../product-specs/internationalization.md),
[`../../PLANS.md`](../../PLANS.md)

## Goal

Bring the docs, visual design contract, and live templates back into sync.
Done means the user-visible drift found in this audit is fixed, stale plan
state is moved out of `active/`, and the docs harness/build both pass.

## Approach

- Compare the product specs and design doc against `_layouts/`,
  `_data/i18n.yml`, and `assets/css/style.scss`.
- Fix small live-site mismatches in-place, preferring existing patterns.
- Remove unused markup hooks when no CSS, JS, or doc contract depends on them.
- Ship any completed plan still listed as active and update the roadmap.
- Run `bash scripts/docs-check.sh --mode lint` and `bundle exec jekyll build`.

## Open questions

- None.

## Decision log

- 2026-04-27: Treat the hardcoded home eyebrow as functional UI text because
  it changes with the same language toggle as the rest of the home hero.
- 2026-04-27: Restore the post-header brand icon instead of weakening the
  spec; `page.html` and the CSS already define this pattern.
