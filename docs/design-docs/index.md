# Design docs index

Long-form notes that explain _why_ the repo is the way it is. Anything here
should outlive any single change.

| Doc                                  | Status | Summary                                                                        |
| ------------------------------------ | ------ | ------------------------------------------------------------------------------ |
| [`core-beliefs.md`](core-beliefs.md) | Active | Agent-first operating principles for this repo. The harness is built on these. |

## When to add one

A design doc is the right artifact when:

- The decision is irreversible or expensive to revisit.
- A future contributor (human or agent) would otherwise have to re-derive the
  reasoning from code archaeology.
- The decision constrains multiple files or domains.

If the decision only affects one feature, write a `product-specs/` file
instead. If it's a one-time plan, write an `exec-plans/active/` file.

## Format

- Filename: `kebab-case.md`.
- Top of file: a one-sentence summary, then `Last reviewed: YYYY-MM-DD`.
- Sections: `Context`, `Decision`, `Consequences`, `Alternatives considered`.
- Mark superseded docs with `Status: Superseded by [link]` at the top instead
  of deleting them.
