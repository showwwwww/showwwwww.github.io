# SEO + GEO

Owns: the SEO/GEO behavior of `_layouts/default.html`, the `_config.yml`
fields read by `jekyll-seo-tag` and `jekyll-sitemap`, the `robots.txt` and
`llms.txt` at the repo root, and (jointly with
[`internationalization.md`](internationalization.md)) the `html[lang]` and
`hreflang` rules.

Last reviewed: 2026-04-27.

## Intent

Every public route should be discoverable and well-described to:

1. Classic search engines (Google, Bing, DuckDuckGo).
2. Generative engines and AI crawlers (ChatGPT/GPTBot, Claude/ClaudeBot,
   Perplexity, Google AI Overviews).

The site is small and static, so the tools are small and static too: a
plugin-driven `<head>`, a generated sitemap, a hand-curated `llms.txt`,
and a permissive `robots.txt`. There is no analytics, no JavaScript SEO,
and no per-post tag-soup boilerplate.

## Behavior

### Per-page `<head>`

- The default layout emits a locale-aware `<title>` of the form
  `"<page title> · <site title in page.lang>"`. The site-title segment
  comes from `_data/i18n.yml` (`us.site.title` / `cn.site.title`), so a
  CN post renders `修的技术博客` in the SSR HTML even before the toggle
  JS runs.
- `<html lang>` reflects the **content** language: `en-US` for US posts
  and pages, `zh-CN` for CN posts. It is set SSR-side from `page.lang`
  and **never rewritten by the language-toggle JS**. The toggle only
  updates `html[data-lang]` (the chrome-language hint).
- `jekyll-seo-tag` (`{% seo title=false %}`) emits:
  - `<link rel="canonical">`.
  - `<meta name="description">` from `page.description`, falling back to
    `page.excerpt`, falling back to `site.description`.
  - Open Graph (`og:title`, `og:type`, `og:url`, `og:site_name`,
    `og:image`, `og:description`).
  - Twitter card (summary or summary_large_image when an image is set).
  - JSON-LD: `WebSite` on the home page, `BlogPosting` on posts, with
    `author` resolved from the top-level `author:` block in
    `_config.yml`.
- The default layout suppresses the plugin's `<title>` so it can render
  a locale-aware one (see above). The plugin's other tags are kept as
  emitted.
- Open Graph locale: `og:locale` is set from `page.lang` (`en_US` or
  `zh_CN`). When a paired translation exists, `og:locale:alternate` is
  emitted with the other locale.
- Hreflang: on a post page with a paired translation, the layout emits
  `<link rel="alternate" hreflang="...">` for both languages plus
  `hreflang="x-default"` pointing at the US version. Pages and the
  homepage do not emit hreflang.
- The Atom feed link (`{% feed_meta %}`) and the existing favicon /
  apple-touch-icon links are unchanged.

### Crawler-facing files at the site root

- `/robots.txt`: allows all user agents on all routes and points at
  `/sitemap.xml`. No path-specific disallows. Generative-engine
  crawlers are explicitly allowed (this is the default; the file just
  documents it).
- `/sitemap.xml`: produced by `jekyll-sitemap`. Includes every public
  HTML page including the per-language post URLs (`/<slug>/` and
  `/cn/<slug>/`).
- `/llms.txt`: hand-curated Markdown summary aimed at LLM-based
  discovery, following the [llmstxt.org](https://llmstxt.org)
  convention. It contains:
  - A short paragraph describing the site, its author, and its scope.
  - A linked list of posts grouped by language, each with a one-line
    summary auto-derived from the post excerpt.
  - Pointers to the feed and sitemap.

### Site identity

- `_config.yml` carries `url:` (absolute), `title:`, `description:`,
  `lang:` (`en-US` default), `author:` (name + url), and `social:`
  (links list). These are consumed by `jekyll-seo-tag` for JSON-LD,
  Open Graph, and Twitter card output.

## Constraints

- No third-party analytics or tracking pixels in the head. SEO/GEO is
  achieved with first-party static markup only.
- Plugins must be GitHub-Pages-supported (`jekyll-seo-tag`,
  `jekyll-sitemap`, `jekyll-feed` qualify).
- Per-post `description:` and `image:` frontmatter are optional — the
  excerpt + site icon fallbacks are good enough for a default post and
  let authors stay focused on content.
- Hreflang URLs must be absolute and resolve to a real route. The
  layout uses `absolute_url` to enforce this.
- `html[lang]` reflects content language; `html[data-lang]` reflects
  chrome language. They are allowed to disagree (a CN reader on an
  English-only post sees `lang="en-US"`, `data-lang="cn"`). See
  [`internationalization.md`](internationalization.md).

## Out of scope

- Per-language sitemap (`<xhtml:link rel="alternate">` per URL). Both
  language versions already appear as separate URLs in `/sitemap.xml`,
  and `hreflang` on the page itself is enough at current scale.
- Auto-generated `llms.txt`. The list is small enough to maintain via
  a Liquid template that iterates over `site.posts`; revisit if the
  post count grows past ~50.
- Per-post Open Graph images. The site icon is the fallback; add a
  per-post `image:` frontmatter only when a post benefits from a
  custom social card.
- Structured data beyond what `jekyll-seo-tag` emits (e.g. FAQ,
  HowTo, BreadcrumbList). Posts are essays, not knowledge-base
  entries; the BlogPosting schema is enough.
- A `Last-Modified` HTTP header strategy. GitHub Pages controls
  caching; we do not.

## Changelog

- 2026-04-27: Initial spec. Added `jekyll-seo-tag` and `jekyll-sitemap`
  to the build, switched `<html lang>` to be SSR-driven from
  `page.lang`, added hreflang on paired posts, added `/robots.txt` and
  `/llms.txt` at the site root.
