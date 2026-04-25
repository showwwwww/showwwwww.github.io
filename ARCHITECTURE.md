# ARCHITECTURE.md

> Top-level map of this repo. If `AGENTS.md` is the table of contents, this
> file is the floor plan: what lives where, and what is allowed to depend on
> what. Modeled after [matklad's ARCHITECTURE.md
> convention](https://matklad.github.io/2021/02/06/ARCHITECTURE.md.html).

Last reviewed: 2026-04-25.

## Domains

This is a personal blog. The product breaks into four small domains:

1. **Site shell** — chrome around every page (sidebar, head, footer,
   language toggle).
2. **Content** — Markdown posts and standalone pages, plus their frontmatter.
3. **Theme** — visual design tokens and SCSS, plus the 404 page.
4. **Build** — Jekyll config, dependency pinning, formatter, git hooks, CI.

A separate cross-cutting concern, the **agent harness**, sits on top of all
four. It is the docs system + per-runtime hooks that keep agents legible to
the repo and the repo legible to agents.

## Layering

The site is small enough that we don't enforce layering with linters yet, but
the intended dependency direction is one-way:

```
   ┌────────────────────────────────────────────────┐
   │             Site shell  (_layouts/)            │
   │  default.html → home.html / page.html /        │
   │                  post.html                     │
   └────────────────────────────────────────────────┘
                     ▲              ▲
                     │              │
   ┌────────────────────┐    ┌─────────────────────┐
   │   Content          │    │   Theme             │
   │  _posts/*.md       │    │  assets/css/        │
   │  *.markdown        │    │   style.scss        │
   │                    │    │  404.html           │
   └────────────────────┘    └─────────────────────┘
                     ▲              ▲
                     │              │
   ┌────────────────────────────────────────────────┐
   │                Build                           │
   │  _config.yml · Gemfile · .githooks/pre-commit  │
   │  .prettierrc.json · .prettierignore            │
   └────────────────────────────────────────────────┘
```

Allowed dependencies:

- Site shell may reference theme tokens (CSS class names, the stylesheet
  path) and the Jekyll site object (`site.posts`, `page.title`, etc).
- Content depends on the site shell only via `layout:` frontmatter. A post
  must not reference a layout that doesn't exist.
- Theme depends on nothing. SCSS is leaf code.
- Build depends on nothing inside the site; it owns environment + tooling.

Disallowed:

- Inline `<style>` blocks in `_layouts/` or posts. All visual styling lives in
  `assets/css/style.scss`.
- Inline JS in posts. Posts are content; behavior lives in layouts.
- Liquid logic in `assets/css/style.scss` beyond the front-matter triple-dash
  fence Jekyll requires.
- Any file outside `_posts/`, `*.markdown`, or layouts referencing
  `site.posts` directly. Use the sidebar / home layout.

## File map

| Path                                                                         | Owner doc                                                                                                                                                                          | Notes                                                                                                                                            |
| ---------------------------------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------ |
| `index.markdown`                                                             | [`docs/CONTENT.md`](docs/CONTENT.md)                                                                                                                                               | Renders via `home` layout.                                                                                                                       |
| `404.html`                                                                   | [`docs/DESIGN.md`](docs/DESIGN.md)                                                                                                                                                 | Hand-authored, Liquid-aware, ignored by Prettier.                                                                                                |
| `_posts/*.markdown`                                                          | [`docs/CONTENT.md`](docs/CONTENT.md)                                                                                                                                               | US posts. Filename must match `YYYY-MM-DD-title.md(arkdown)`. `lang: us` is set automatically by `_config.yml` defaults.                         |
| `_posts/cn/*.markdown`                                                       | [`docs/CONTENT.md`](docs/CONTENT.md), [`docs/product-specs/internationalization.md`](docs/product-specs/internationalization.md)                                                   | CN translations. Paired to a US post by a shared `ref:` frontmatter slug. `lang: cn` and `permalink: /cn/:title/` set by `_config.yml` defaults. |
| `_data/i18n.yml`                                                             | [`docs/product-specs/internationalization.md`](docs/product-specs/internationalization.md)                                                                                         | Central US/CN source for functional UI text and the sidebar site name / tagline.                                                                 |
| `_layouts/default.html`                                                      | [`docs/product-specs/sidebar-navigation.md`](docs/product-specs/sidebar-navigation.md), [`docs/product-specs/internationalization.md`](docs/product-specs/internationalization.md) | Owns the sidebar, language toggle, and content frame.                                                                                            |
| `_layouts/home.html`                                                         | [`docs/product-specs/sidebar-navigation.md`](docs/product-specs/sidebar-navigation.md)                                                                                             | Welcome hero + recent posts.                                                                                                                     |
| `_layouts/post.html`                                                         | [`docs/product-specs/post-layout.md`](docs/product-specs/post-layout.md)                                                                                                           | Header, content, prev/next nav.                                                                                                                  |
| `_layouts/page.html`                                                         | [`docs/product-specs/post-layout.md`](docs/product-specs/post-layout.md)                                                                                                           | Minimal page chrome.                                                                                                                             |
| `assets/css/style.scss`                                                      | [`docs/DESIGN.md`](docs/DESIGN.md)                                                                                                                                                 | Single stylesheet; uses CSS variables.                                                                                                           |
| `_config.yml`                                                                | [`docs/RELIABILITY.md`](docs/RELIABILITY.md)                                                                                                                                       | Site metadata plus Jekyll excludes for internal Markdown; Prettier ignores it.                                                                   |
| `Gemfile` / `Gemfile.lock`                                                   | [`docs/RELIABILITY.md`](docs/RELIABILITY.md)                                                                                                                                       | Pinned for GitHub Pages compatibility.                                                                                                           |
| `.githooks/pre-commit`                                                       | [`docs/RELIABILITY.md`](docs/RELIABILITY.md)                                                                                                                                       | Activated via `git config core.hooksPath .githooks`.                                                                                             |
| `.prettierrc.json`, `.prettierignore`                                        | [`docs/RELIABILITY.md`](docs/RELIABILITY.md)                                                                                                                                       | Prettier 3 config; see `.cursor/rules/prettier-formatting.mdc`.                                                                                  |
| `.cursor/`, `.codex/`, `.claude/`, `AGENTS.md`, `CLAUDE.md`, `scripts/docs/` | [`docs/design-docs/core-beliefs.md`](docs/design-docs/core-beliefs.md)                                                                                                             | The agent harness itself.                                                                                                                        |
| `_site/`, `.jekyll-cache/`, `vendor/`                                        | —                                                                                                                                                                                  | Generated. Never commit, never edit.                                                                                                             |

## What's deliberately not here

- No JavaScript framework. The only inline JS is the sidebar toggle and
  language selector in `_layouts/default.html`.
- No Sass partials. One file (`style.scss`) is enough at this scale.
- No CI workflow files yet. GitHub Pages does its own build; if we add CI it
  will live in `.github/workflows/` and own its own row in the file map above.
- `_data/i18n.yml` is the only data file. It owns functional UI text and
  the localized sidebar site name and tagline; other content text stays in
  Markdown/frontmatter/config until a future content source replaces it.
- Per-language post content is split across `_posts/` (US) and
  `_posts/cn/` (CN), paired by a shared `ref:` slug in frontmatter. URL
  prefixes (`/:title/` and `/cn/:title/`) and `lang` values are set
  centrally via `defaults` in `_config.yml`, not per file. See
  [`docs/product-specs/internationalization.md`](docs/product-specs/internationalization.md).

## Who owns the harness

The agent harness (this file, `AGENTS.md`, the per-runtime hook configs, and
`scripts/docs/`) is owned by `docs/design-docs/core-beliefs.md`. Any change
to how the harness behaves must update that doc in the same commit.
