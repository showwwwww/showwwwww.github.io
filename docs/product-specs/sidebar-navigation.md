# Sidebar navigation

Owns: `_layouts/default.html`, `_layouts/home.html`.

Last reviewed: 2026-04-25.

## Intent

The sidebar is the site's primary navigation. Readers should be able to find
any post in two clicks: open the menu, scan by year, click through. The
sidebar exists so the content area can be a quiet, single-column reading
surface.

## Behavior

- The sidebar always shows the circular site icon, site title, and tagline at
  the top. The title and tagline strings come from `us.site` / `cn.site` in
  `_data/i18n.yml` and follow the US/CN language toggle.
- It lists "Pages" (any `*.markdown` with a `title:` frontmatter, excluding
  `index` and the `404`), sorted alphabetically by title.
- It lists "Articles" once per language. The sidebar renders two parallel
  blocks under the "Articles" heading — one wrapped in
  `data-lang-section="us"`, one wrapped in `data-lang-section="cn"` — each
  filtered to posts whose `lang` matches. Within a block, posts are
  grouped by year (descending), then by date within each year (also
  descending). CSS hides the block whose attribute does not match the
  active `html[data-lang]`, so the user only ever sees one list.
- A language with zero posts shows the localized "No articles yet."
  message inside its own section.
- The currently-viewed page or post is marked active (`is-active` class
  applied via Liquid; styling lives in `assets/css/style.scss`).
- A footer at the bottom of the sidebar shows GitHub / Twitter / email links
  if (and only if) the corresponding values in `_config.yml` differ from the
  Jekyll boilerplate defaults. The link labels are functional text from
  `_data/i18n.yml`.
- On viewports ≤ 768 px, the sidebar collapses behind a hamburger toggle.
  Tapping a link auto-closes the sidebar.
- Sidebar labels participate in the site language toggle. US English is the
  default, and CN labels replace the chrome when the language layer selects
  CN.
- Functional nav labels and the sidebar site name and tagline are read from
  `_data/i18n.yml`. Page titles and post titles are content text and come
  from their content sources.

The home layout (`home.html`) reuses the sidebar (it inherits from
`default.html`) and renders a welcome hero plus the five most recent posts
inside the content area. The recent-posts list uses the same per-language
`data-lang-section` mechanism as the sidebar, so it always reflects the
active language.

## Constraints

- No JavaScript framework. The only inline JS allowed on this layout is the
  sidebar toggle and the language selector; both live at the bottom of
  `_layouts/default.html`.
- Keyboard-accessible: the toggle is a `<button>` with `aria-controls` and
  `aria-expanded`.
- The sidebar must render correctly with zero posts — falling back to a
  "No articles yet." message — because that's the empty state on a fresh
  clone.
- The active-link styling must rely on `page.url` matching, not URL slug
  parsing in JS.

## Out of scope

- Search inside the sidebar.
- Tag / category filtering. Categories render on the post header
  (`post.html`) but are not navigable from the sidebar.
- Pagination. The sidebar lists every post; if that becomes a perf problem
  we'll add pagination as a separate spec, not bolt it onto this one.

## Changelog

- 2026-04-25: Spec promoted from inline knowledge during the docs-harness
  setup. Behavior reflects the current `_layouts/default.html` and
  `home.html`; no behavioral change in this commit.
- 2026-04-25: Sidebar chrome now participates in the US/CN language toggle.
- 2026-04-25: Functional sidebar labels now read from `_data/i18n.yml`, while
  content titles remain outside the functional dictionary.
- 2026-04-25: Articles list and home recent-posts list are rendered per
  language using `data-lang-section` blocks, hidden in CSS based on
  `html[data-lang]`.
- 2026-04-26: Sidebar header now includes the transparent circular site icon
  above the site title.
- 2026-04-26: Site title and tagline in the sidebar read from
  `us.site` / `cn.site` in `_data/i18n.yml` (removed the standalone About
  page; no `about` route).
