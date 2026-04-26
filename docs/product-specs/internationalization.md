# Internationalization

Owns: `_data/i18n.yml`, language behavior in `_layouts/default.html`, the
post/page conventions in [`../CONTENT.md`](../CONTENT.md), and the
per-language post defaults in `_config.yml`.

Last reviewed: 2026-04-25.

## Intent

Readers should see both the site chrome and long-form post content in the
language that best matches their environment, while still having a visible
manual override. Functional UI text is centralized in a translation
dictionary; long-form content is authored once per language as plain
Markdown.

## Behavior

### Functional UI text

- Functional UI text lives in `_data/i18n.yml`, split into `us` and `cn`
  branches. Examples: navigation labels, theme and language button labels,
  section labels, footer labels, empty states, post-navigation labels, 404
  system copy, the sidebar site name and tagline (`us.site` / `cn.site`),
  and the home welcome hero (`us.home.welcome_title` /
  `us.home.welcome_subtitle`, plus the `cn` branch).
- The GitHub header link (circular mark, left of the language and theme
  controls) uses `data-i18n-aria-label="footer.github"` so the accessible
  name stays on the `footer.github` key even though the control left the
  sidebar footer.
- The site renders US English by default. On first load, a Chinese browser
  environment switches the chrome to CN; other environments stay on US.
- A language toggle appears at the top-right of every page. Selecting it
  switches between `EN` and `中` and stores the choice in `localStorage`.
  The button renders both labels stacked and cross-fades between them based
  on `html[data-lang]`; `prefers-reduced-motion` disables the transition.
- The theme toggle accessible label is also localized. Its visible state is
  icon-only, while its title uses the active theme label (`theme.dark` or
  `theme.light`) for the selected language.
- The selected language updates `html[lang]`, `html[data-lang]`, visible
  layout labels, accessible labels, and functional system text such as the
  404 page.
- Layouts should not introduce new hardcoded functional strings when a key
  in `_data/i18n.yml` would work.

### Content text

- Each post is authored as one Markdown file per language. US posts live at
  `_posts/YYYY-MM-DD-slug.markdown`. CN translations live at
  `_posts/cn/YYYY-MM-DD-slug.markdown`.
- Both files in a pair carry a shared `ref:` slug in frontmatter (e.g.
  `ref: welcome-to-jekyll`). `lang:` is set automatically by the
  `defaults` block in `_config.yml`; do not hand-write it. See
  [`../CONTENT.md`](../CONTENT.md) for full frontmatter conventions.
- Each post has its own canonical URL: US at `/:title/`, CN at
  `/cn/:title/`. Both are real, indexable pages.
- Listings in the sidebar (`_layouts/default.html`) and the home page
  (`_layouts/home.html`) render two parallel sections, wrapped in
  `data-lang-section="us"` and `data-lang-section="cn"`. CSS in
  `assets/css/style.scss` hides the section whose attribute does not match
  `html[data-lang]`. The same mechanism is available to other layouts that
  need per-language rendering.
- Post prev/next navigation in `_layouts/post.html` is filtered by
  `page.lang`, so a CN post links only to other CN posts.
- When a post has a paired translation in the other language,
  `_layouts/default.html` emits a `data-translation-href` attribute on
  `<body>`. The toggle JS uses it to navigate to the paired URL after
  persisting the language choice. Without a pairing, only the chrome flips
  and the URL stays.
- The sidebar site name and tagline are localized: `us.site` / `cn.site` in
  `_data/i18n.yml` drive the header block; `_config.yml` `title` and
  `description` remain for Jekyll and feeds.
- Other content text (page bodies under `*.markdown`) remains in its
  content source; those parts are currently English aside from the paired
  CN post files under `_posts/cn/`.

### Fallback when a translation is missing

- If a US post has no CN counterpart and the user is in CN mode, the
  chrome flips to CN, but the URL and the post body stay on the US
  version. There is no "missing translation" banner.

## Constraints

- No build plugin, JavaScript framework, or per-language Jekyll plugin.
- US English is the source/default for functional copy; CN copy is a
  client-side enhancement for chrome and a separate Markdown file for
  content.
- Content URLs are locale-prefixed (`/cn/:title/`), but routing is driven
  by `_config.yml` `defaults` rather than a build-time locale loop.
- Layouts must not introduce new hardcoded functional strings when a key
  in `_data/i18n.yml` would work. They may render content strings from
  content sources.
- The toggle must remain keyboard-accessible and visible in both light and
  dark mode.

## Out of scope

- Machine translation.
- Translating `index.markdown` or other page bodies beyond the sidebar
  name and tagline keys and the home welcome hero.
- RSS/feed localization.
- Per-language sitemaps or `hreflang` tags.
- A "missing translation" stub UI when only the US version exists.

## Changelog

- 2026-04-26: Localized the home welcome hero (title + subtitle) via
  `us.home.welcome_title` / `us.home.welcome_subtitle` (and the `cn`
  branch). The `welcome_title` / `welcome_subtitle` keys were removed
  from `_config.yml`; `_layouts/home.html` now reads from the i18n
  dictionary and swaps via `data-i18n` like the sidebar header.
- 2026-04-26: Localized sidebar site name and tagline via `us.site` /
  `cn.site`; Jekyll `site.title` / `site.description` in `_config.yml`
  remain for build metadata and the feed.
- 2026-04-26: Added localized theme control labels under `theme.switch`,
  `theme.dark`, and `theme.light`.
- 2026-04-26: Language toggle CN label switched from `CN` to `中`; the
  button renders both labels stacked and cross-fades between them on
  language change.
- 2026-04-26: 404 system copy now uses only `error404.title` plus an
  HTML-enabled `error404.hint` return-home link.
- 2026-04-25: Added US/CN language detection and a persistent top-right
  toggle for translated site chrome.
- 2026-04-25: Clarified that `_data/i18n.yml` owns functional UI text only;
  content text stays with content sources.
- 2026-04-25: Extended i18n to long-form post content. Added `_posts/cn/`
  convention with shared `ref:` pairing, locale-prefixed URLs
  (`/:title/` and `/cn/:title/`), per-language listings via
  `data-lang-section`, lang-filtered post prev/next, and toggle navigation
  to the paired URL when present. Removed the prior "no locale-specific
  generated pages" constraint.
