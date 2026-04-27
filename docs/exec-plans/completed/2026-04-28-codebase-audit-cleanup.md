# Codebase audit cleanup

Outcome: shipped on 2026-04-28; starter drift, design conflicts, docs/spec
drift, and stale active plan state were cleaned up together.
Status: shipped
Owner: Codex
Opened: 2026-04-28
Updated: 2026-04-28
Related: [PLANS.md](../../PLANS.md), [DESIGN.md](../../DESIGN.md), [RELIABILITY.md](../../RELIABILITY.md), [CONTENT.md](../../CONTENT.md), [product-specs/](../../product-specs/)

## Goal

Audit the small Jekyll blog for design conflicts, documentation drift, and stale historical notes. Done means the highest-signal drifts are fixed in code/docs together and the repo checks still pass.

## Approach

- Compare the docs/spec claims against layouts, stylesheet, config, posts, and tooling.
- Patch focused conflicts that are clearly historical drift rather than new product work.
- Update owner docs and roadmap state in the same change.
- Run the docs lint and Jekyll build checks, then archive this plan.

## Open questions

- None yet.

## Decision log

- 2026-04-28: Treat this as a docs-plus-implementation cleanup because it crosses design, reliability, and product-spec surfaces.
- 2026-04-28: Removed the starter `twitter_username: jekyllrb`, aligned SEO
  social links with visible profile links, removed viewport-scaled/negative
  title typography, and documented the responsive toolbar adjustment.
- 2026-04-28: Archived the completed SEO/GEO plan; leaving shipped work in
  `active/` was itself roadmap drift.
- 2026-04-28: Verification passed with Prettier, docs lint, and the
  Bundler-backed Jekyll build.
