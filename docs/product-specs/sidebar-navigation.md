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
  the top, centered in the column (icon above title, CJK line-breaking allowed).
  The title and tagline strings come from `us.site` / `cn.site` in
  `_data/i18n.yml` and follow the US/CN language toggle. The home link wraps
  the icon and the site name; the name span has class `site-name` for
  `data-i18n="site.title"`.
- It lists "Pages" (any `*.markdown` with a `title:` frontmatter, excluding
  `index` and the `404`), sorted alphabetically by title.
- It lists "Articles" once per language. The sidebar renders two parallel
  blocks under the "Articles" heading — one wrapped in
  `data-lang-section="us"`, one wrapped in `data-lang-section="cn"` — each
  filtered to posts whose `lang` matches. Within a block, posts are
  grouped by year (descending), then by date within each year (also
  descending). Each list item shows the post title only (no month/day
  beside the title). CSS hides the block whose attribute does not match the
  active `html[data-lang]`, so the user only ever sees one list.
- A language with zero posts shows the localized "No articles yet."
  message inside its own section.
- The currently-viewed page or post is marked active (`is-active` class
  applied via Liquid; styling lives in `assets/css/style.scss`).
- The **GitHub** profile link (when `github_username` in `_config.yml` is
  set and not the Jekyll default) is a circular mark button in the fixed
  top-right `header-toolbar`, immediately **left of** the LinkedIn control.
  It uses the same localized accessible name as the old footer label
  (`data-i18n-aria-label="footer.github"`, Octicons-style path SVG).
- The **LinkedIn** profile link is a circular mark button in the fixed
  top-right `header-toolbar`, immediately **right of** the GitHub control and
  immediately **left of** the X control. It links to
  `https://www.linkedin.com/in/showwwwww11/` and uses the official LinkedIn
  glyph with a localized accessible name (`footer.linkedin`).
- The **X** profile link is a circular mark button in the fixed top-right
  `header-toolbar`, immediately **right of** the LinkedIn control and
  immediately **left of** the Instagram control. It links to
  `https://x.com/showwwwww_` and uses the official X mark with a localized
  accessible name (`footer.x`).
- The **Instagram** profile link is a circular mark button in the fixed
  top-right `header-toolbar`, immediately **right of** the X control
  and before the language/theme controls. It links to
  `https://www.instagram.com/showwwwww_11/` and uses the original-color
  Instagram mark with a localized accessible name (`footer.instagram`).
- The fixed `header-toolbar` includes a circular theme button to the
  **right of** the language toggle. It shows a sun SVG in light mode and a
  moon SVG in dark mode, toggles `html[data-theme]`, and persists explicit
  choices in `localStorage`.
- A footer at the bottom of the sidebar shows **Twitter** and **email** links
  if (and only if) the corresponding values in `_config.yml` differ from the
  Jekyll boilerplate defaults. If neither is set, the footer block is omitted
  entirely. The link labels are functional text from `_data/i18n.yml`. The
  row is center-aligned in the sidebar.
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
inside the content area. The welcome hero eyebrow, title, subtitle, hint, and
latest-posts heading are localized from the `home.*` branch in
`_data/i18n.yml`, swapped via `data-i18n` like the sidebar header. The
recent-posts list uses the same per-language
`data-lang-section` mechanism as the sidebar, so it always reflects the
active language.

## Constraints

- No JavaScript framework. The only inline JS allowed on this layout is the
  early theme bootstrap plus the sidebar toggle, theme selector, and language
  selector; the runtime controls live at the bottom of
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
- 2026-04-26: Sidebar article links no longer show a per-item month/day; year
  group headings remain.
- 2026-04-26: Site identity in the sidebar (icon, name, tagline) is
  center-aligned; site title string uses a `span.site-name` inside the
  `a.site-title` home link. Footer links are center-aligned in the bar.
- 2026-04-26: GitHub link moved to `header-toolbar` (circular mark, left of
  language toggle); footer keeps Twitter and email only.
- 2026-04-26: Added a localized light/dark theme toggle to
  `header-toolbar`, to the right of the language toggle.
- 2026-04-26: Theme toggle is now a circular icon button that animates
  between sun (light) and moon (dark) states.
- 2026-04-26: Language toggle now renders both labels (`EN` and `中`)
  overlaid and cross-fades between them on language change.
- 2026-04-26: Home welcome hero (title + subtitle) is now localized via
  `us.home.welcome_title` / `us.home.welcome_subtitle` in `_data/i18n.yml`
  and follows the language toggle.
- 2026-04-27: Added a LinkedIn profile mark to `header-toolbar`, placed
  between the GitHub mark and the language/theme controls.
- 2026-04-28: Added an Instagram profile mark to `header-toolbar`, placed
  immediately right of LinkedIn and linked to the public Instagram profile.
- 2026-04-28: Added an X profile mark to `header-toolbar`, placed immediately
  right of LinkedIn and linked to the public X profile.
- 2026-04-27: Home welcome hero eyebrow now reads from
  `home.welcome_eyebrow` instead of a hardcoded English string.
