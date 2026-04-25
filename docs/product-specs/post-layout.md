# Post + page layout

Owns: `_layouts/post.html`, `_layouts/page.html`, `404.html`.

Last reviewed: 2026-04-25.

## Intent

Posts are the primary reading surface; pages and the 404 are quieter
variants of the same shape. Each layout should put the reader's content in
a single, generously-padded column with the smallest possible amount of
chrome above and below.

## Behavior

### `post.html`

- Renders categories (one per `<span>`) above the title, only when the post
  has at least one category.
- Renders the post title as `<h1>` and the date below it (formatted "Month
  D, YYYY"), plus an optional author when the frontmatter sets one. The title
  is content text and comes from post frontmatter.
- Renders the post body via `{{ content }}`.
- At the foot, renders prev/next navigation. Neighbors are computed from
  `site.posts` filtered by `page.lang`, so a CN post links only to other
  CN posts and never crosses languages. If either neighbor is missing,
  the slot is filled with an empty `<span>` so the flex layout stays
  balanced.
- Prev/next labels and accessible navigation labels participate in the US/CN
  language toggle.
- When a paired translation in the other language exists (matched via the
  shared `ref:` frontmatter key), `_layouts/default.html` emits
  `data-translation-href` on `<body>`. The toggle JS uses it to navigate
  to the paired URL after persisting the language choice. See
  [`internationalization.md`](internationalization.md).

### `page.html`

- Same outer chrome as posts (sidebar via `default`), but inside the content
  area shows only the page title and content. No date, no prev/next.
- This is what `about.markdown` and any future standalone page should use.
- Page titles and bodies are content text and do not live in `_data/i18n.yml`.

### `404.html`

- Uses the `default` layout for the sidebar.
- Shows the same "welcome hero" component as `home.html` but with the
  eyebrow replaced by `404` and a one-line link back home.
- Its title, subtitle, and home-link hint participate in the US/CN language
  toggle.
- Permalink is `/404.html` so GitHub Pages serves it for missing routes.

## Constraints

- Title escaping: every `page.title` rendered into HTML must go through the
  Jekyll `escape` filter. The `404` is a static string and is exempt.
- Dates use `date_to_xmlschema` for the `<time>` `datetime` attribute and
  the human-friendly `%B %-d, %Y` format for the visible label.
- No inline `<style>` blocks. All styling comes from
  `assets/css/style.scss`.
- These layouts are excluded from Prettier (`.prettierignore`) because they
  contain Liquid; do not reformat them by hand.

## Out of scope

- Comments / reactions.
- Author bio block. If we add one, it gets its own spec, not a paragraph in
  this one.
- TOC generation for long posts.

## Changelog

- 2026-04-25: Spec promoted from inline knowledge during the docs-harness
  setup. Behavior reflects the current files; no behavioral change in this
  commit.
- 2026-04-25: Post/page/404 chrome now participates in the US/CN language
  toggle.
- 2026-04-25: Clarified that post/page titles are content text; only
  functional layout labels use `_data/i18n.yml`.
- 2026-04-25: Post prev/next navigation is now lang-filtered (no
  cross-language jumps), and the language toggle navigates to the paired
  translation when one exists.
