# Generated docs

Reserved for documentation that is produced by a script rather than
hand-authored.

Last reviewed: 2026-04-25.

## Status

Empty on purpose. We have not yet decided what to auto-generate. Candidates
the harness has thought about:

- **Post index.** A flat list of `_posts/*.markdown` with title, date, and
  categories. Useful for agents searching for prior art before writing a
  new post.
- **Layout map.** A diagram of `_layouts/*.html` and which layouts inherit
  from which.
- **Asset inventory.** Anything under `assets/` with size + last-modified.

## Contract for files in this directory

If you add a generated file here:

1. The first line must be a comment that says
   `<!-- GENERATED FILE — do not edit by hand. Regenerate with: <command> -->`.
2. The generator script must be checked in under `scripts/` and must be
   idempotent (running it twice in a row produces no diff).
3. Add a row to the table in [`../README.md`](../README.md) and a check in
   `scripts/docs-check.sh --mode lint` that confirms the file is up to
   date.
4. Add the regeneration command to the `## Generate` section of this file.

## Generate

_No generators yet._
