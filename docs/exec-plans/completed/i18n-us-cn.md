# I18N: US/CN site chrome

Outcome: Shipped. Functional UI text now switches between US and CN via the
top-right toggle, with browser-language detection and `localStorage`
persistence. Content text was deliberately left out of scope — see the
follow-up plan in [`active/2026-04-25-content-i18n-us-cn.md`](../active/2026-04-25-content-i18n-us-cn.md).

Status: shipped
Owner: site shell + content docs
Started: 2026-04-25
Shipped: 2026-04-25

## Goal

Add a lightweight internationalization layer for the static Jekyll site:

- Render US English by default.
- Detect Chinese browser environments and switch to CN copy on first load.
- Let readers toggle language from the right side of the page header.
- Keep functional UI copy centralized in `_data/i18n.yml`.
- Keep the implementation static-host friendly: no plugins, no framework, no
  build pipeline change.

## Scope

- Shared layout chrome in `_layouts/default.html`.
- Functional labels for home, page, post navigation, sidebar, and 404 system
  text.
- Content text remains in Markdown/frontmatter/config and is not centralized
  in `_data/i18n.yml`.
- Central US/CN functional copy in `_data/i18n.yml`.
- Styling in `assets/css/style.scss`.
- Product/design/content docs that describe the behavior.

## Non-goals

- Translating every post body automatically.
- Locale-specific URLs such as `/cn/`.
- Build-time locale generation.

## Verification

- `bundle exec jekyll build`
- `bash scripts/docs-check.sh --mode lint`
