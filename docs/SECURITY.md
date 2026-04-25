# SECURITY.md

Last reviewed: 2026-04-25.

## Threat model

This is a static blog served by GitHub Pages. The realistic threats are:

1. **Account takeover.** Someone takes over the GitHub account and pushes
   malicious content. Mitigated by GitHub-side controls (2FA, hardware
   keys, recovery codes) outside the scope of this repo.
2. **Supply-chain via Ruby gems.** A compromised Jekyll dependency could
   inject content at build time. Pins in `Gemfile` reduce blast radius;
   a `bundle update` should never happen casually.
3. **Supply-chain via `npx prettier`.** The pre-commit hook downloads
   Prettier on demand. A compromised npm package could exfiltrate staged
   file contents at commit time. Mitigated by pinning to `prettier@^3`
   and by Prettier being a high-visibility package.
4. **Agent-introduced backdoors.** A coding agent acting on a malicious
   prompt could edit `.githooks/pre-commit`, `.cursor/hooks/`,
   `.codex/hooks/`, `.claude/hooks/`, or `scripts/docs/` to run arbitrary
   code on commit / on next agent turn. The defense is human review of
   diffs touching those paths.

## Rules

- Hook scripts (anything under `.githooks/`, `.cursor/hooks/`,
  `.codex/hooks/`, `.claude/hooks/`, `scripts/docs/`) must be
  human-reviewed on every change. The lint script does not — and cannot —
  detect a malicious hook.
- No secrets in this repo. The site is public; everything committed is
  public. `.env`, `.envrc`, `*.pem`, `id_rsa*`, and similar are listed in
  `.gitignore` patterns by GitHub's defaults; leave them gitignored.
- Outbound HTTP from hook scripts is forbidden. The Prettier hook reaches
  npm via `npx`; no other hook should make a network call.
- `scripts/docs-check.sh` reads only Git metadata and the working tree.
  If we ever add a hook that needs network access, it gets its own spec
  and a row in `QUALITY_SCORE.md` because it expands the threat surface.

## Out of scope

- DoS protection (GitHub Pages handles it).
- Content authenticity / signing of posts.
- A vulnerability disclosure process for a one-author blog.

## What to do if something looks wrong

- Commit lands you didn't make: rotate GitHub credentials, audit
  `.githooks/`, `.cursor/`, `.codex/`, `.claude/`, and `scripts/docs/`
  with `git log -p`, then revert.
- Hook script grew a network call you didn't add: revert the offending
  commit, add a `git log` audit entry to
  [`exec-plans/tech-debt-tracker.md`](exec-plans/tech-debt-tracker.md),
  and re-run the doc-check lint to confirm the harness is intact.
