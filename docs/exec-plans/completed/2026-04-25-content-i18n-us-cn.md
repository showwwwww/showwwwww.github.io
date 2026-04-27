# Content i18n: US/CN post bodies

Outcome: Shipped. US and CN post bodies now live as paired Markdown files
under `_posts/` and `_posts/cn/`, with language-scoped listings,
language-scoped prev/next navigation, and paired translation redirects on
the language toggle.

Status: shipped
Owner: site shell + content docs
Opened: 2026-04-25
Updated: 2026-04-27
Shipped: 2026-04-27
Related:
[`../../product-specs/internationalization.md`](../../product-specs/internationalization.md),
[`../../CONTENT.md`](../../CONTENT.md),
[`../../product-specs/post-layout.md`](../../product-specs/post-layout.md),
[`../../product-specs/sidebar-navigation.md`](../../product-specs/sidebar-navigation.md),
[`../completed/i18n-us-cn.md`](../completed/i18n-us-cn.md)

## Goal

Extend US/CN i18n past the chrome to long-form post content, by storing each
translation as its own Markdown file and giving it its own canonical URL.
Functional UI text continues to live in `_data/i18n.yml`; content text lives
where content already lives.

## Approach

- Authoring: US posts stay at `_posts/YYYY-MM-DD-slug.markdown`. CN
  translations live at `_posts/cn/YYYY-MM-DD-slug.markdown`. Both files
  carry a shared `ref:` slug in frontmatter for pairing.
- Routing: add `defaults` in `_config.yml` so `_posts/cn/*` gets `lang: cn`
  and `permalink: /cn/:title/`, while `_posts/*` gets `lang: us` and
  `permalink: /:title/`.
- Listings: in `_layouts/default.html` (sidebar) and `_layouts/home.html`
  (home), render two parallel lists wrapped in `data-lang-section="us"` and
  `data-lang-section="cn"`. CSS hides the section whose attribute does not
  match `html[data-lang]`.
- Post navigation: in `_layouts/post.html`, compute prev/next from
  `site.posts | where: "lang", page.lang` so a CN post links to other CN
  posts. Emit `data-translation-href` on `<body>` when the paired post in
  the other language exists.
- Toggle behavior: extend the existing toggle JS in `_layouts/default.html`
  so that on a post page with a paired translation, switching language
  navigates to the paired URL after persisting the choice. Without a
  pairing, only the chrome flips and the URL stays.
- Fallback: if a US post has no CN counterpart and the user is in CN mode,
  the chrome flips but the body and URL stay on the US version. No
  "missing translation" UI in this iteration.
- Docs: update `internationalization.md`, `CONTENT.md`, `post-layout.md`,
  `sidebar-navigation.md`, and the file map in `ARCHITECTURE.md` in the
  same change.

## Open questions

- None.

## Decision log

- 2026-04-25: Subfolder layout (`_posts/cn/...`) chosen over filename
  suffix (`*.cn.markdown`) because it lets `_config.yml` `defaults`
  apply `lang` and `permalink` cleanly per scope without per-file
  frontmatter.
- 2026-04-25: `ref:` chosen as the pairing key (vs. matching filenames)
  so CN translations can adopt different slugs over time without
  breaking pairing or the toggle navigation.
- 2026-04-25: Fallback behavior is "stay on US, flip chrome"; no stub
  page or banner. Keeps the change small; revisit if missing
  translations pile up.
- 2026-04-27: Shipped the plan after confirming the code, content docs, and
  product specs already implement the planned US/CN post-body split.
