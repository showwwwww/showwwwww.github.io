# Product specs

One file per user-visible feature. Each spec describes _what the feature is
supposed to do_, not _how the code happens to do it today_. The code can
change; the spec should change deliberately, with a short note in its
**Changelog** section.

Last reviewed: 2026-04-28.

## Specs

| Spec                                                 | Owns these files                                                               |
| ---------------------------------------------------- | ------------------------------------------------------------------------------ |
| [`internationalization.md`](internationalization.md) | `_data/i18n.yml`, language toggle, functional UI text                          |
| [`sidebar-navigation.md`](sidebar-navigation.md)     | `_layouts/default.html`, `_layouts/home.html`                                  |
| [`post-layout.md`](post-layout.md)                   | `_layouts/post.html`, `_layouts/page.html`, `404.html`                         |
| [`seo.md`](seo.md)                                   | SEO/GEO behavior of `_layouts/default.html`, `robots.txt`, `llms.txt`, sitemap |

## Format

- Filename: `kebab-case.md`.
- Sections:
  1. **Intent.** Two sentences on what this feature is for, from the
     reader's point of view.
  2. **Behavior.** Bullet list of the observable behavior. Prefer what a
     user sees and can do; mention HTML, CSS classes, or `data-*` hooks only
     when they are part of the feature contract.
  3. **Constraints.** Things that must remain true (accessibility, mobile
     breakpoints, no JS dependencies, etc.).
  4. **Out of scope.** Explicit non-goals.
  5. **Changelog.** Append-only `YYYY-MM-DD: <change>` entries.

Specs are short on purpose. If a spec needs five pages, the feature is too
big and should be broken up.

## When to add one

When you add a layout, an `_includes/` partial used in more than one place,
or a standalone page that is not a post. Posts themselves are governed by
[`../CONTENT.md`](../CONTENT.md), not by per-post specs.
