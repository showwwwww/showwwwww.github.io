# Internationalization

Owns: `_data/i18n.yml` and language behavior in `_layouts/default.html` for
functional UI text.

Last reviewed: 2026-04-25.

## Intent

Readers should see the site chrome in the language that best matches their
environment, while still having a visible manual override. The feature keeps
the blog static-host friendly and does not introduce locale-specific routes.

## Behavior

- The site renders US English by default.
- On first load, a Chinese browser environment switches the chrome to CN.
  Other environments stay on US English.
- A language toggle appears at the top-right of every page. Selecting it
  switches between `US` and `CN` and stores the choice in `localStorage`.
- The selected language updates `html[lang]`, visible layout labels,
  accessible labels, and functional system text such as the 404 page.
- Functional UI text lives in `_data/i18n.yml`, split into `us` and `cn`
  branches. Examples: navigation labels, button labels, section labels,
  footer labels, empty states, post-navigation labels, and 404 system copy.
- Content text does not live in `_data/i18n.yml`. Examples: site title,
  tagline, page titles, home hero copy, post titles, excerpts, and article
  bodies.

## Constraints

- No build plugin, JavaScript framework, or locale-specific generated pages.
- US English is the source/default for functional copy; CN copy is a
  client-side enhancement.
- Content text remains in content/frontmatter/config today and can move to a
  DB-backed source later without changing the functional i18n contract.
- Layouts should not introduce new hardcoded functional strings when a key in
  `_data/i18n.yml` would work. They may render content strings from content
  sources.
- The toggle must remain keyboard-accessible and visible in both light and
  dark mode.

## Out of scope

- Machine translation.
- `/cn/` or `/us/` routes.
- RSS/feed localization.
- Content localization or DB-backed content loading.

## Changelog

- 2026-04-25: Added US/CN language detection and a persistent top-right
  toggle for translated site chrome.
- 2026-04-25: Clarified that `_data/i18n.yml` owns functional UI text only;
  content text stays with content sources.
