# DESIGN.md — design tokens, layout, accessibility

Owns: `assets/css/style.scss`, the visual structure of `_layouts/*.html`,
and `404.html`.

Last reviewed: 2026-04-25.

## Design tokens

All tokens are CSS custom properties declared at the top of
`assets/css/style.scss`. Read that file for the source of truth; this doc
captures the _intent_.

| Token group       | Examples                                                                                                                  | Intent                                                                                                                                                              |
| ----------------- | ------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Layout            | `--sidebar-width: 280px`, `--content-max: 760px`, `--content-pad: 3rem`                                                   | The sidebar is fixed-width; the content column has a hard max-width and generous padding. Don't let either drift far from these values without revisiting the spec. |
| Color (light)     | `--color-bg`, `--color-surface`, `--color-text`, `--color-text-soft`, `--color-muted`, `--color-border`, `--color-accent` | Soft off-white background, near-black text, a single accent (`#4f7cff`).                                                                                            |
| Color (sidebar)   | `--color-sidebar-bg` (`#0f1115`), `--color-sidebar-fg`, `--color-sidebar-active-*`                                        | The sidebar is intentionally dark in both themes. It frames the content; it does not need to match the page background.                                             |
| Color (dark mode) | Same tokens overridden inside `@media (prefers-color-scheme: dark)`                                                       | Dark mode is automatic; no toggle, no `localStorage`.                                                                                                               |
| Typography        | `--font-sans`, `--font-mono`                                                                                              | System font stacks, including PingFang / Hiragino / YaHei for CJK. No webfonts, no FOUT.                                                                            |
| Surface           | `--radius: 8px`, `--shadow-sm`, `--shadow-md`                                                                             | One radius value, two shadow levels.                                                                                                                                |

If you need a new token, add it in the same `:root` block and document its
intent here. Don't introduce one-off magic values inside individual
selectors.

## Layout rules

- Single-column reading surface, max width `--content-max` (760 px).
- Sidebar on the left at `--sidebar-width` (280 px).
- Sidebar identity uses a circular transparent PNG above the site title; the
  source artwork is clipped to avoid square black corners.
- Language toggle fixed at the top-right of the viewport. It is intentionally
  small chrome, separate from the sidebar.
- Below 768 px, the sidebar collapses behind a hamburger; the content fills
  the viewport.
- Vertical rhythm comes from `line-height: 1.65` on body text and matching
  margin defaults on headings; do not override per-component.

## Dark mode

- Triggered by `prefers-color-scheme: dark`. There is intentionally no UI
  toggle.
- The sidebar palette does not change between modes (it's already dark in
  light mode). Only the content area tokens flip.
- New components must work in both modes. If a value needs to differ, route
  it through a token, not a `@media` block inside the component.

## Accessibility

Non-negotiable:

- Body text contrast is AA at minimum on both themes. Spot-check with a
  contrast tool before merging a token change.
- Keyboard navigation works without JS for links. The sidebar and language
  controls are real `<button>` elements.
- `aria-label`, `aria-controls`, and `aria-expanded` on the sidebar toggle
  stay in sync with the visual state. The language toggle keeps its
  accessible label and pressed state in sync with the selected language.
- Skip-to-content is provided implicitly by the `<main id="content">`
  landmark. If we add visible "Skip to content" UI it goes under a separate
  spec.
- `prefers-reduced-motion: reduce` should be honored by any future
  animation. We don't have any today.

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
