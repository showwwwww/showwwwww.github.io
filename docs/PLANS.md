# PLANS.md — short-term roadmap

> What's actively in flight, what's queued, and what's deferred. This file
> is the human-readable counterpart to [`exec-plans/`](exec-plans/) — keep
> it short.

Last reviewed: 2026-04-27.

## Now (in flight)

- SEO + GEO optimization: `jekyll-seo-tag` + `jekyll-sitemap`, locale-aware
  `<title>` and `<html lang>`, `hreflang` on paired posts, and crawler
  files (`/robots.txt`, `/llms.txt`) at the site root. Tracking in
  [`exec-plans/active/2026-04-27-seo-geo-optimization.md`](exec-plans/active/2026-04-27-seo-geo-optimization.md).
  Spec: [`product-specs/seo.md`](product-specs/seo.md).

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

- Doc/design/dead-code audit: fixed a home-hero i18n drift, restored the
  post-header brand icon promised by the layout spec, removed unused toolbar
  class hooks, and cleaned stale plan state. Archived at
  [`exec-plans/completed/2026-04-27-doc-design-dead-code-audit.md`](exec-plans/completed/2026-04-27-doc-design-dead-code-audit.md).
- US/CN long-form post content i18n. Archived at
  [`exec-plans/completed/2026-04-25-content-i18n-us-cn.md`](exec-plans/completed/2026-04-25-content-i18n-us-cn.md).
- Agent harness: `AGENTS.md`, `ARCHITECTURE.md`, `docs/`,
  `scripts/docs-check.sh`, and per-runtime hooks for Cursor / Codex /
  Claude Code.
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
