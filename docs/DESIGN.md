# DESIGN.md — design tokens, layout, accessibility

Owns: `assets/css/style.scss`, the visual structure of `_layouts/*.html`,
and `404.html`.

Last reviewed: 2026-04-25.

## Design tokens

All tokens are CSS custom properties declared at the top of
`assets/css/style.scss`. Read that file for the source of truth; this doc
captures the _intent_.

| Token group       | Examples                                                                                                                                                                         | Intent                                                                                                                                                              |
| ----------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Layout            | `--sidebar-width: 280px`, `--content-max: 760px`, `--content-pad: 3rem`                                                                                                          | The sidebar is fixed-width; the content column has a hard max-width and generous padding. Don't let either drift far from these values without revisiting the spec. |
| Color (light)     | `--color-bg`, `--color-surface`, `--color-text`, `--color-text-soft`, `--color-muted`, `--color-border`, `--color-accent`                                                        | Soft off-white background, near-black text, a single accent (`#4f7cff`).                                                                                            |
| Color (sidebar)   | `--color-sidebar-bg`, `--color-sidebar-fg`, `--color-sidebar-heading`, `--color-sidebar-muted`, `--color-sidebar-active-*`, `--color-sidebar-border`, `--color-sidebar-hover-bg` | The sidebar uses its own palette so it can frame the content with a slightly different surface than the page background. Both light and dark variants are defined.  |
| Color (dark mode) | Same tokens declared in `:root`; light mode overrides them under `html[data-theme="light"]`                                                                                      | Dark is the HTML/default theme. The theme script may switch to light based on saved choice or system preference.                                                    |
| Typography        | `--font-sans`, `--font-mono`                                                                                                                                                     | System font stacks, including PingFang / Hiragino / YaHei for CJK. No webfonts, no FOUT.                                                                            |
| Surface           | `--radius: 8px`, `--shadow-sm`, `--shadow-md`                                                                                                                                    | One radius value, two shadow levels.                                                                                                                                |

If you need a new token, add it in the same `:root` block and document its
intent here. Don't introduce one-off magic values inside individual
selectors.

## Layout rules

- Single-column reading surface, max width `--content-max` (760 px).
- Sidebar on the left at `--sidebar-width` (280 px).
- Sidebar identity uses a circular transparent PNG above the site title; the
  source artwork is clipped to avoid square black corners.
- Top-right of the viewport: a fixed `header-toolbar` with compact circular
  social links, the i18n language button, and a circular theme button to its
  right; when `site.github_username` is set (non-boilerplate), the circular
  GitHub mark appears first, followed by the LinkedIn mark. This chrome is
  intentionally small, separate from the sidebar.
- Below 768 px, the sidebar collapses behind a hamburger; the content fills
  the viewport.
- Vertical rhythm comes from `line-height: 1.65` on body text and matching
  margin defaults on headings; do not override per-component.

## Theme system

- Supported themes are `dark` and `light`, represented by
  `html[data-theme="dark"]` and `html[data-theme="light"]`.
- Dark is the static HTML default. Before the stylesheet loads,
  `_layouts/default.html` checks `localStorage`; when no saved choice exists,
  it follows `prefers-color-scheme` and falls back to dark.
- The top-right theme toggle switches only between light and dark and stores
  the explicit choice in `localStorage`. While no explicit choice exists, a
  system theme change updates the page. The control is circular and shows a
  sun icon for light mode and a moon icon for dark mode.
- Both the content area and the sidebar palette flip with the theme. The
  sidebar still uses its own `--color-sidebar-*` tokens so it can be a
  distinct surface from the page background in either mode.
- New components must work in both modes. If a value needs to differ, route
  it through a token, not a component-local `@media` block.

## Accessibility

Non-negotiable:

- Body text contrast is AA at minimum on both themes. Spot-check with a
  contrast tool before merging a token change.
- Keyboard navigation works without JS for links. The sidebar, theme, and
  language controls are real `<button>` elements.
- `aria-label`, `aria-controls`, and `aria-expanded` on the sidebar toggle
  stay in sync with the visual state. The theme and language toggles keep
  their accessible labels and pressed states in sync with the selected
  theme/language.
- Skip-to-content is provided implicitly by the `<main id="content">`
  landmark. If we add visible "Skip to content" UI it goes under a separate
  spec.
- `prefers-reduced-motion: reduce` is honored by the theme icon transition
  and should be honored by any future animation.

## What lives in `assets/css/style.scss` (and what doesn't)

- All visual styling lives in this one file. No CSS-in-JS, no per-layout
  `<style>` blocks.
- The file is processed by Jekyll's SCSS converter; the empty front matter
  fence at the top is required and must stay.
- It is **not** Liquid-aware in practice. Don't put Liquid expressions
  inside it.

## Out of scope

- Multiple themes beyond light/dark.
- A design system bigger than what fits in one CSS file. If we ever need
  partials, that's a separate exec-plan.
- Animations and transitions, except for the sidebar slide on mobile.

## Changelog

- 2026-04-25: Document promoted from inline knowledge in `style.scss`. No
  visual change in this commit.
- 2026-04-25: Added the top-right language toggle to the layout and
  accessibility rules.
- 2026-04-26: Added circular site icon styling for the sidebar identity.
- 2026-04-26: Sidebar site identity is column-centered; post/page content
  headers include a smaller circular brand image; top bar controls use flex
  centering for their inner labels/icons; article `h1` title rules are scoped
  under `.post` / `.page` to avoid clashing with sidebar list labels.
- 2026-04-26: GitHub profile link moved from the sidebar footer to a circular
  mark button in `header-toolbar`, left of the language toggle; Twitter and
  email stay in the sidebar footer.
- 2026-04-26: Replaced automatic-only dark mode with a light/dark theme
  system. Dark is the HTML default; first load follows saved preference or
  system color scheme, and the toolbar theme toggle persists explicit
  choices.
- 2026-04-26: Theme toggle moved to the right of the language button and now
  renders animated sun/moon SVG icons with reduced-motion support.
- 2026-04-26: Theme toggle inner icons use `pointer-events: none` so the
  click target is always the surrounding `<button>` regardless of where in
  the circle the pointer lands.
- 2026-04-26: Sidebar palette now flips with the theme. Added a light
  variant of `--color-sidebar-*` and a `--color-sidebar-hover-bg` token so
  the nav hover state isn't a hardcoded translucent white.
- 2026-04-26: 404 return-home link now has a small accent highlight and keeps
  link underlines disabled on hover.
- 2026-04-27: Added a LinkedIn mark link to the top-right toolbar between the
  GitHub mark and the language/theme controls.
- 2026-04-27: Restored the post-header circular brand image to match the
  page-header pattern, localized the home hero eyebrow, and removed unused
  per-network toolbar class hooks.
