# Sidebar navigation

Owns: `_layouts/default.html`, `_layouts/home.html`.

Last reviewed: 2026-04-25.

## Intent

The sidebar is the site's primary navigation. Readers should be able to find
any post in two clicks: open the menu, scan by year, click through. The
sidebar exists so the content area can be a quiet, single-column reading
surface.

## Behavior

- The sidebar always shows the site title and tagline at the top.
- It lists "Pages" (any `*.markdown` with a `title:` frontmatter, excluding
  `index` and the `404`), sorted alphabetically by title.
- It lists "Articles" (anything in `_posts/`), grouped by year (descending),
  then by date within each year (also descending).
- The currently-viewed page or post is marked active (`is-active` class
  applied via Liquid; styling lives in `assets/css/style.scss`).
- A footer at the bottom of the sidebar shows GitHub / Twitter / email links
  if (and only if) the corresponding values in `_config.yml` differ from the
  Jekyll boilerplate defaults.
- On viewports ≤ 768 px, the sidebar collapses behind a hamburger toggle.
  Tapping a link auto-closes the sidebar.

The home layout (`home.html`) reuses the sidebar (it inherits from
`default.html`) and renders a welcome hero plus the five most recent posts
inside the content area.

## Constraints

- No JavaScript framework. The sidebar toggle is the only inline JS allowed
  on this layout, and it lives at the bottom of `_layouts/default.html`.
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
