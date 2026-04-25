# Localize the home welcome hero

Outcome: Shipped. Home welcome title and subtitle now flip with the US/CN
toggle via `us.home.welcome_title` / `us.home.welcome_subtitle` (and the
`cn` branch). `_config.yml` `welcome_title` / `welcome_subtitle` were
removed; `_layouts/home.html` reads from the i18n dictionary and the
existing `data-i18n` JS in `_layouts/default.html` does the runtime swap.
Verified with `bundle exec jekyll build` and
`bash scripts/docs-check.sh --mode lint`.

Status: shipped
Owner: site shell + content docs
Opened: 2026-04-26
Shipped: 2026-04-26
Related:
[`../../product-specs/internationalization.md`](../../product-specs/internationalization.md),
[`../../product-specs/sidebar-navigation.md`](../../product-specs/sidebar-navigation.md),
[`../active/2026-04-25-content-i18n-us-cn.md`](2026-04-25-content-i18n-us-cn.md),
[`../completed/i18n-us-cn.md`](../completed/i18n-us-cn.md)

## Goal

Make the home page hero (`Hi, I'm show.` / blurb) flip language with the
existing US/CN toggle, the same way the sidebar title and tagline already
do. After this change, no user-visible string in the home hero or sidebar
remains English-only.

## Approach

- Add `home.welcome_title` and `home.welcome_subtitle` to both `us` and
  `cn` branches of `_data/i18n.yml`. The CN copy keeps the same shape as
  the existing CN tagline (笔记、实验与长文).
- Switch `_layouts/home.html` to render `us.home.welcome_title` /
  `us.home.welcome_subtitle` with `data-i18n` attributes, matching the
  pattern already used for `site.title` / `site.tagline`. The runtime JS
  in `_layouts/default.html` swaps the text on language change.
- Drop the now-unused `welcome_title` and `welcome_subtitle` keys from
  `_config.yml`. Keep `title` and `description`; Jekyll uses those for
  feed metadata.
- Update `docs/product-specs/internationalization.md`: remove
  welcome-hero from the out-of-scope list, move it from "content text" to
  "functional UI text", and add a changelog entry.
- Update `docs/product-specs/sidebar-navigation.md` so the home-layout
  paragraph notes that the welcome hero is localized too.
- Run `bash scripts/docs-check.sh --mode lint`.

## Open questions

- The "Welcome" eyebrow above the title in `_layouts/home.html` is still
  hardcoded English. Out of scope for this change; tracked separately if
  it ever bothers a reader. (Cheapest fix: add `home.welcome_eyebrow` and
  swap it the same way.)
- `index.markdown` body text is still English-only. Same separate-plan
  note as in [`2026-04-25-content-i18n-us-cn.md`](2026-04-25-content-i18n-us-cn.md).

## Decision log

- 2026-04-26: Move the strings into `_data/i18n.yml` rather than adding a
  parallel `welcome_title_cn` key in `_config.yml`. Keeps a single
  dictionary for translatable chrome and reuses the existing `data-i18n`
  swap path; no new template branches needed.
- 2026-04-26: Remove `welcome_title` / `welcome_subtitle` from
  `_config.yml` instead of leaving them as dead defaults. Jekyll metadata
  uses `title` / `description`, not these.
