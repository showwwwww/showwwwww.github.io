# SEO + GEO optimization

Status: in-progress
Owner: site shell + harness
Opened: 2026-04-27
Updated: 2026-04-27
Related:
[`../../product-specs/seo.md`](../../product-specs/seo.md),
[`../../product-specs/internationalization.md`](../../product-specs/internationalization.md),
[`../../product-specs/sidebar-navigation.md`](../../product-specs/sidebar-navigation.md),
[`../../RELIABILITY.md`](../../RELIABILITY.md),
[`../../../ARCHITECTURE.md`](../../../ARCHITECTURE.md)

## Goal

Make the site discoverable and well-described to both classic search engines
(Google, Bing) and generative engines (ChatGPT, Claude, Perplexity, Google
AI Overviews). "Done" means every public route emits a correct
`<title>`, meta description, canonical URL, Open Graph + Twitter card,
`hreflang` to the paired translation when one exists, and Article/WebSite
JSON-LD; the site exposes a sitemap, a robots policy, and an `/llms.txt`
summary for AI crawlers.

## Approach

- **Site identity (`_config.yml`).** Set the absolute `url`, add a
  top-level `author:` block (used by JSON-LD + sitemap), set `lang: en-US`
  as the site default. Exclude `llms.txt` and `robots.txt` only if Jekyll
  rewrites them; otherwise leave them as plain static files.
- **Plugins (`Gemfile` + `_config.yml`).** Add `jekyll-seo-tag` and
  `jekyll-sitemap`. Both are GitHub-Pages-supported. Pin to the same
  major versions Pages uses so local builds match.
- **Default layout `<head>`.** Use `{% seo title=false %}` to emit
  canonical, OG, Twitter, JSON-LD, and meta description. Keep a custom
  `<title>` so the per-page locale (`page.lang`) can pick the matching
  site title suffix from `_data/i18n.yml`. SSR `<html lang>` is now
  derived from `page.lang` (not hardcoded `en-US`). Emit `og:locale` and
  pair it with `og:locale:alternate` when the translation exists.
- **Hreflang (paired posts).** When `page.ref` resolves to a paired post
  in the other language, emit two `<link rel="alternate" hreflang>`
  entries plus an `x-default` pointing at the US version. Do this only on
  post pages; pages and the home page have no per-language pairs.
- **Toggle JS.** Stop the inline language toggle from rewriting
  `html.lang`. The chrome language is a UI preference (`html[data-lang]`);
  the document language must match the actual content body. Update the
  i18n spec to match.
- **Sitemap + robots.** `jekyll-sitemap` generates `/sitemap.xml`. Add
  `/robots.txt` at the repo root referencing the sitemap and allowing
  all UAs. Keep both as plain files (no Liquid) so they remain stable.
- **GEO (`/llms.txt`).** Add a short `llms.txt` at the repo root that
  summarizes the site for LLM-based discovery (one paragraph + a list of
  canonical URLs grouped by language). Keep it manually curated so it
  stays accurate without a generator.
- **Docs.** New spec: `docs/product-specs/seo.md`. Update
  `internationalization.md` (remove "hreflang out of scope", document the
  new `html[lang]` rule), `RELIABILITY.md` (new plugins + new public
  files), `product-specs/index.md` (add SEO row), `ARCHITECTURE.md` (add
  rows for `robots.txt`, `llms.txt`, and the new spec), and the
  `code_to_docs` mapping in `scripts/docs-check.sh`.

## Open questions

- Per-post `image:` frontmatter for OG previews. Skip for now; the site
  icon falls back as the default `og:image`. Add when a post genuinely
  benefits from a custom social card.
- Whether to add `/.well-known/security.txt`. Out of scope here; covered
  by `docs/SECURITY.md` if/when we have a vuln-disclosure process.
- Sitemap localization (`<xhtml:link rel="alternate">` per URL). Skip;
  the per-language URLs already appear in the sitemap, and `hreflang`
  on the page itself is enough for current scale.

## Decision log

- 2026-04-27: Chose `jekyll-seo-tag` over rolling our own `<head>`.
  Reason: GH-Pages supports it, it covers OG + Twitter + JSON-LD in one
  tag, and the site's "low-surface-area" principle prefers a small
  managed dependency over hand-maintained meta tags.
- 2026-04-27: Suppress `jekyll-seo-tag`'s `<title>` (`title=false`) and
  keep a custom `<title>` so the trailing site-name segment respects
  `page.lang`. The plugin's `og:title` / `twitter:title` still come from
  `page.title`, which is already in the post's content language.
- 2026-04-27: SSR `<html lang>` is driven by `page.lang`, not by the
  client-side language toggle. Reason: `lang` should describe the
  document content, not the chrome preference. The toggle still updates
  `html[data-lang]` for chrome styling and i18n string swaps.
- 2026-04-27: `hreflang` is post-page-only. Pages and the home page
  don't have a per-language counterpart in this model, so emitting
  hreflang there would be misleading.
- 2026-04-27: `llms.txt` is hand-curated, not generated. The site is
  small enough that a generator would cost more maintenance than it
  saves; revisit if the post count climbs past ~50.
