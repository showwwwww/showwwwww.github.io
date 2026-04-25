# CONTENT.md — voice, tone, and post conventions

Owns: `_posts/**`, `index.markdown`, plus future standalone pages.

Last reviewed: 2026-04-26.

## Voice

- First person singular. This is a personal blog.
- Direct and concrete. Show the code or the screenshot before explaining.
- Past tense for things that happened, present tense for things that are
  still true. Avoid future tense unless it's a literal commitment.
- No hype. "Fast" needs a number; "easy" needs a counter-example.

## Frontmatter

Every post starts with this block:

```
---
layout: post
title:  "Sentence case title — no trailing period"
date:   YYYY-MM-DD HH:MM:SS +0800
categories: lowercase space separated
ref:    kebab-case-translation-key
---
```

Notes:

- `layout` is always `post` for items under `_posts/`. Standalone pages use
  `page`.
- `title` uses sentence case (only the first letter capitalized; proper
  nouns stay capitalized). No trailing period. Two spaces after the colon
  are conventional in the Jekyll templates and Prettier preserves them.
- `date` includes the local time and `+0800` offset. The time portion is
  required; Jekyll uses it for prev/next ordering.
- `categories` is optional. When present, keep it to 1–3 short tokens.
- `ref` is the shared key that pairs a post with its translation in the
  other language. Use the same kebab-case slug in both files; the
  language toggle and translation lookup rely on it. Required on every
  post, even when no translation exists yet (so a future translation can
  be paired without editing the original).
- Do not set `lang` by hand. The `defaults` block in `_config.yml`
  assigns `lang: us` to anything in `_posts/` and `lang: cn` to anything
  in `_posts/cn/`.
- Do not put content text into `_data/i18n.yml`. Titles, excerpts, and bodies
  are content and stay in Markdown/frontmatter until a future DB-backed
  content source replaces them.

## Filenames

`YYYY-MM-DD-kebab-case-slug.markdown`. `.md` and `.markdown` are both
accepted; the existing post is `.markdown` so prefer that for visual
consistency.

## Per-language post layout

Every post is authored as one Markdown file per language:

- US (default): `_posts/YYYY-MM-DD-slug.markdown` → `/:title/`.
- CN translation: `_posts/cn/YYYY-MM-DD-slug.markdown` → `/cn/:title/`.

Two files are translation pairs only when they share the same `ref:` in
frontmatter, not by filename. The date and `ref` should match **across
that pair**; titles, bodies, categories, and excerpts may diverge to
whatever reads best in each language. A US post and a CN post with the
same date but **different** `ref` values (for example, the template welcome
post in `_posts/` and a standalone article in `_posts/cn/`) are
independent: the language toggle resolves by `ref`, not by date or path.

A post does not need to have a translation. If only a US version exists,
the language toggle still flips the chrome to CN but stays on the US URL
and body. See
[`product-specs/internationalization.md`](product-specs/internationalization.md)
for the full content-i18n contract.

## Body conventions

- Headings start at `##`. The post title (rendered by `_layouts/post.html`)
  is the only `<h1>`.
- Wrap inline code with backticks. For multi-line code, use fenced blocks
  with a language identifier (`ruby`, `bash`, `js`, etc.).
- Prefer reference-style links at the bottom for URLs that appear more than
  once or that are long enough to break wrapping:

  ```
  See the [Jekyll docs][jekyll-docs] for details.

  [jekyll-docs]: https://jekyllrb.com/docs/home
  ```

- Don't autoplay anything. No raw `<script>` tags in posts. If you need
  interactivity, write a spec under `docs/product-specs/` first.

## Excerpts

Jekyll auto-generates an excerpt from the first paragraph. The home layout
truncates excerpts to ~140 characters. Write the first paragraph as a
self-contained summary and you'll get a usable excerpt for free.

## Drafts

Use `_drafts/` (gitignored is fine; not currently configured). Run with
`bundle exec jekyll serve --drafts` to preview. Don't commit drafts; they
are noise in the post list.

## When you finish a post

- The pre-commit hook will format the Markdown with Prettier 3
  (`printWidth: 80`, `proseWrap: preserve`). Write Prettier-clean Markdown
  so the hook stays a no-op.
- Run `bundle exec jekyll build` once to make sure nothing crashes.
- The doc-check hook (`scripts/docs-check.sh --mode hook ...`) may remind
  you to review CONTENT.md when you touch any file under `_posts/`. Add a
  small note here if the change updates pairing behavior, `ref` usage, or
  other conventions; otherwise a routine content-only edit can skip a doc
  update when nothing below is contradicted.

## Out of scope

- Comments / reactions.
- Newsletter signup forms.
- Series / cross-post chaining. If we add a "series" feature later, it gets
  its own spec under `docs/product-specs/`.
- Machine translation. Paired US/CN posts are authored by hand.
- Translating standalone pages (`index.markdown` and any future
  `*.markdown` pages) — those are out of scope for the current i18n
  contract.
- Managing long-form or page body text in `_data/i18n.yml`; that file holds
  functional UI strings plus the localized site name and tagline used in the
  sidebar.
