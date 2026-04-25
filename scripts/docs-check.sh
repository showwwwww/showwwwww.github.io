#!/usr/bin/env bash
# scripts/docs-check.sh
# ---------------------------------------------------------------------------
# Single entry point for the docs harness. Runs in two modes:
#
#   --mode lint
#       Verify the docs system. Strict; intended for CI and manual runs.
#       Exits non-zero when something is wrong.
#
#   --mode hook --runtime <cursor|codex|claude> --event <post-edit|stop>
#       Read the runtime's hook JSON payload on stdin and emit JSON shaped
#       for that runtime+event so the agent gets a docs-update reminder.
#       Always exits 0 (fails open). Diagnostics go to stderr.
#
# This script is the contract between the docs system (`docs/`, `AGENTS.md`,
# `ARCHITECTURE.md`) and every per-runtime hook config under `.cursor/`,
# `.codex/`, and `.claude/`. Keep it small and Bash-3.2-compatible (macOS).
# ---------------------------------------------------------------------------

set -uo pipefail

# ---------- helpers --------------------------------------------------------

log()  { printf '[docs-check] %s\n' "$*" >&2; }
warn() { printf '[docs-check] WARN: %s\n' "$*" >&2; }
die()  { printf '[docs-check] ERROR: %s\n' "$*" >&2; exit 1; }

repo_root() {
  git rev-parse --show-toplevel 2>/dev/null
}

have() { command -v "$1" >/dev/null 2>&1; }

# Map a single repo-relative path to a space-separated list of doc paths
# that are responsible for it. Keep this in sync with the file map in
# ARCHITECTURE.md. If a path has no owner, print nothing.
code_to_docs() {
  local path="$1"
  case "$path" in
    _layouts/default.html|_layouts/home.html)
      echo "docs/product-specs/sidebar-navigation.md docs/DESIGN.md" ;;
    _layouts/post.html|_layouts/page.html|404.html)
      echo "docs/product-specs/post-layout.md docs/DESIGN.md" ;;
    _layouts/*|_includes/*)
      echo "docs/product-specs/index.md docs/DESIGN.md" ;;
    assets/css/*|assets/css/*.scss|assets/**/*.scss|assets/**/*.css)
      echo "docs/DESIGN.md" ;;
    _posts/*)
      echo "docs/CONTENT.md" ;;
    index.markdown|about.markdown|*.markdown)
      echo "docs/CONTENT.md" ;;
    _config.yml|Gemfile|Gemfile.lock)
      echo "docs/RELIABILITY.md ARCHITECTURE.md" ;;
    .githooks/*|.prettierrc.json|.prettierignore)
      echo "docs/RELIABILITY.md" ;;
    .cursor/*|.codex/*|.claude/*|scripts/docs-check.sh|AGENTS.md|CLAUDE.md|ARCHITECTURE.md)
      echo "docs/design-docs/core-beliefs.md docs/RELIABILITY.md" ;;
    docs/*)
      echo "" ;; # editing a doc is itself a doc edit; no further mapping
    *)
      echo "" ;;
  esac
}

# Returns 0 if the path is itself a documentation file (in `docs/`, or one
# of the top-level harness docs).
is_doc_path() {
  case "$1" in
    docs/*|AGENTS.md|ARCHITECTURE.md|CLAUDE.md) return 0 ;;
    *) return 1 ;;
  esac
}

# Print the set of repo-relative paths that have changed in the working
# tree (added / modified / deleted / untracked, both staged and unstaged),
# one per line. Untracked files count because a new doc or a new layout
# is exactly the kind of change the harness should reason about.
# Falls back to an empty list on any git failure.
changed_paths() {
  git status --porcelain --untracked-files=all 2>/dev/null \
    | awk '{
        # Strip the two-char status field, handle rename arrows.
        line = substr($0, 4)
        n = index(line, " -> ")
        if (n > 0) line = substr(line, n + 4)
        print line
      }' \
    | sed 's/^"\(.*\)"$/\1/' \
    | sort -u
}

# Same as changed_paths but limited to paths that look like source code
# the harness cares about (excludes docs/, .git, _site/, vendor/).
changed_source_paths() {
  changed_paths | while IFS= read -r p; do
    [ -z "$p" ] && continue
    case "$p" in
      docs/*|.git/*|_site/*|.jekyll-cache/*|vendor/*|node_modules/*) continue ;;
    esac
    printf '%s\n' "$p"
  done
}

# Print the set of changed doc files (touched in the same change set as
# any source files), one per line.
changed_doc_paths() {
  changed_paths | while IFS= read -r p; do
    [ -z "$p" ] && continue
    if is_doc_path "$p"; then
      printf '%s\n' "$p"
    fi
  done
}

# ---------- lint mode ------------------------------------------------------

REQUIRED_FILES=(
  "AGENTS.md"
  "ARCHITECTURE.md"
  "CLAUDE.md"
  "docs/README.md"
  "docs/design-docs/index.md"
  "docs/design-docs/core-beliefs.md"
  "docs/exec-plans/README.md"
  "docs/exec-plans/tech-debt-tracker.md"
  "docs/product-specs/index.md"
  "docs/product-specs/sidebar-navigation.md"
  "docs/product-specs/post-layout.md"
  "docs/references/jekyll-llms.txt"
  "docs/references/prettier-llms.txt"
  "docs/generated/README.md"
  "docs/CONTENT.md"
  "docs/DESIGN.md"
  "docs/PLANS.md"
  "docs/QUALITY_SCORE.md"
  "docs/RELIABILITY.md"
  "docs/SECURITY.md"
)

AGENTS_MD_LINE_CAP=150

run_lint() {
  local root errors=0 missing
  root=$(repo_root) || die "not inside a git repository"
  cd "$root" || die "could not cd to repo root"

  # 1. Required files exist.
  for f in "${REQUIRED_FILES[@]}"; do
    if [ ! -f "$f" ]; then
      warn "missing required doc: $f"
      errors=$((errors + 1))
    fi
  done

  # 2. AGENTS.md is at most AGENTS_MD_LINE_CAP lines.
  if [ -f AGENTS.md ]; then
    local n
    n=$(wc -l < AGENTS.md | tr -d ' ')
    if [ "$n" -gt "$AGENTS_MD_LINE_CAP" ]; then
      warn "AGENTS.md is $n lines; cap is $AGENTS_MD_LINE_CAP. Push detail into docs/."
      errors=$((errors + 1))
    fi
  fi

  # 3. Relative Markdown links inside top-level + docs resolve.
  #    We deliberately skip URLs and anchors-only refs (#frag).
  local doc_files=()
  while IFS= read -r f; do
    doc_files+=("$f")
  done < <(printf '%s\n' AGENTS.md ARCHITECTURE.md CLAUDE.md \
              docs/README.md docs/CONTENT.md docs/DESIGN.md docs/PLANS.md \
              docs/QUALITY_SCORE.md docs/RELIABILITY.md docs/SECURITY.md \
              docs/generated/README.md \
              docs/design-docs/index.md docs/design-docs/core-beliefs.md \
              docs/exec-plans/README.md docs/exec-plans/tech-debt-tracker.md \
              docs/product-specs/index.md \
              docs/product-specs/sidebar-navigation.md \
              docs/product-specs/post-layout.md)

  for f in "${doc_files[@]}"; do
    [ -f "$f" ] || continue
    local dir
    dir=$(dirname "$f")
    # Extract the URL portion of every Markdown link [...](...).
    # First strip fenced code blocks (```...```) and inline backtick spans
    # so we don't false-positive on documented examples; then strip a
    # possible "#anchor" tail from each link target.
    local link
    while IFS= read -r link; do
      [ -z "$link" ] && continue
      case "$link" in
        http://*|https://*|mailto:*|\#*) continue ;;
      esac
      local target=${link%%#*}
      [ -z "$target" ] && continue
      local resolved="$dir/$target"
      if [ -d "$resolved" ] || [ -f "$resolved" ]; then
        continue
      fi
      warn "broken link in $f: $link -> $resolved"
      errors=$((errors + 1))
    done < <(awk '
        BEGIN { in_fence = 0 }
        /^[[:space:]]*```/ { in_fence = !in_fence; next }
        { if (!in_fence) print }
      ' "$f" 2>/dev/null \
        | sed -E 's/`[^`]*`//g' \
        | grep -oE '\]\([^)]+\)' \
        | sed -E 's/^\]\(([^)]*)\)$/\1/')
  done

  # 4. The code_to_docs mapping points only at files that exist. We probe
  #    each unique RHS by feeding a representative LHS through the function.
  local probe_inputs=(
    "_layouts/default.html"
    "_layouts/post.html"
    "_layouts/page.html"
    "_layouts/some-other.html"
    "assets/css/style.scss"
    "_posts/example.md"
    "index.markdown"
    "_config.yml"
    "Gemfile"
    ".githooks/pre-commit"
    ".prettierrc.json"
    ".cursor/hooks.json"
    "AGENTS.md"
  )
  for src in "${probe_inputs[@]}"; do
    local owners
    owners=$(code_to_docs "$src")
    [ -z "$owners" ] && continue
    for owner in $owners; do
      if [ ! -f "$owner" ]; then
        warn "code_to_docs maps $src -> missing doc $owner"
        errors=$((errors + 1))
      fi
    done
  done

  if [ "$errors" -gt 0 ]; then
    log "lint failed with $errors issue(s)."
    exit 1
  fi
  log "lint OK."
}

# ---------- hook mode ------------------------------------------------------

# Build the "what to update" reminder body for an agent. Returns 0 and
# prints the reminder on stdout if a reminder is warranted; returns 1
# (with no stdout) if everything looks fine.
build_reminder() {
  local sources docs_touched=0 reminder
  sources=$(changed_source_paths)
  if [ -z "$sources" ]; then
    return 1
  fi

  local doc_changes
  doc_changes=$(changed_doc_paths)
  if [ -n "$doc_changes" ]; then
    docs_touched=1
  fi

  local owners_for_changed=""
  while IFS= read -r src; do
    [ -z "$src" ] && continue
    local owners
    owners=$(code_to_docs "$src")
    [ -z "$owners" ] && continue
    for o in $owners; do
      owners_for_changed="$owners_for_changed
$o"
    done
  done <<EOF_SOURCES
$sources
EOF_SOURCES

  owners_for_changed=$(printf '%s\n' "$owners_for_changed" \
                         | sed '/^$/d' | sort -u)

  if [ -z "$owners_for_changed" ]; then
    # Nothing the harness owns; stay quiet.
    return 1
  fi

  if [ "$docs_touched" -eq 1 ]; then
    # Heuristic: if the agent already touched at least one of the relevant
    # owner docs, assume they're handling it.
    local already_covered=0
    while IFS= read -r o; do
      [ -z "$o" ] && continue
      if printf '%s\n' "$doc_changes" | grep -Fxq "$o"; then
        already_covered=1
        break
      fi
    done <<EOF_OWNERS
$owners_for_changed
EOF_OWNERS
    if [ "$already_covered" -eq 1 ]; then
      return 1
    fi
  fi

  reminder="Docs harness reminder: source files changed in this turn but no \
relevant docs were updated. Per the principle in docs/design-docs/core-beliefs.md, \
edit code and docs in the same change.

Changed source files:
"
  while IFS= read -r src; do
    [ -z "$src" ] && continue
    reminder="$reminder  - $src
"
  done <<EOF_SOURCES2
$sources
EOF_SOURCES2

  reminder="${reminder}
Owner docs to review (and update if behavior changed):
"
  while IFS= read -r o; do
    [ -z "$o" ] && continue
    reminder="$reminder  - $o
"
  done <<EOF_OWNERS2
$owners_for_changed
EOF_OWNERS2

  reminder="${reminder}
If the change does not affect documented behavior, ignore this and continue. \
If it does, update the listed docs in the same change. \
See AGENTS.md for the full map."

  printf '%s' "$reminder"
  return 0
}

# Per-runtime emitters. Each one writes the JSON Object the runtime expects
# on stdout. They assume `jq` is available; the caller checks first.

emit_cursor_post_edit() {
  local msg=$1
  jq -n --arg m "$msg" '{additional_context: $m}'
}

emit_cursor_stop() {
  local msg=$1
  jq -n --arg m "$msg" '{followup_message: $m}'
}

emit_codex_post_edit() {
  local msg=$1
  jq -n --arg m "$msg" '{
    systemMessage: $m,
    hookSpecificOutput: {
      hookEventName: "PostToolUse",
      additionalContext: $m
    }
  }'
}

emit_codex_stop() {
  local msg=$1
  jq -n --arg m "$msg" '{
    decision: "block",
    reason: $m
  }'
}

emit_claude_post_edit() {
  local msg=$1
  jq -n --arg m "$msg" '{
    hookSpecificOutput: {
      hookEventName: "PostToolUse",
      additionalContext: $m
    }
  }'
}

emit_claude_stop() {
  local msg=$1
  jq -n --arg m "$msg" '{
    decision: "block",
    reason: $m
  }'
}

# Read stdin (a hook payload). Looks for `stop_hook_active: true` and
# returns 0 if present (meaning: don't fire again this turn).
stop_hook_already_active() {
  local payload=$1
  [ -z "$payload" ] && return 1
  have jq || return 1
  local active
  active=$(printf '%s' "$payload" \
             | jq -r '.stop_hook_active // false' 2>/dev/null)
  [ "$active" = "true" ]
}

run_hook() {
  local runtime=$1
  local event=$2
  local root payload reminder

  root=$(repo_root) || { warn "not in a git repo; staying quiet"; exit 0; }
  cd "$root" || { warn "could not cd to repo root; staying quiet"; exit 0; }

  if ! have jq; then
    warn "jq not found on PATH; install jq to enable docs reminders"
    exit 0
  fi

  payload=$(cat 2>/dev/null || true)

  # On Stop events, never loop.
  if [ "$event" = "stop" ] && stop_hook_already_active "$payload"; then
    exit 0
  fi

  if ! reminder=$(build_reminder); then
    # Nothing to say; stay silent.
    exit 0
  fi

  case "$runtime:$event" in
    cursor:post-edit) emit_cursor_post_edit "$reminder" ;;
    cursor:stop)      emit_cursor_stop      "$reminder" ;;
    codex:post-edit)  emit_codex_post_edit  "$reminder" ;;
    codex:stop)       emit_codex_stop       "$reminder" ;;
    claude:post-edit) emit_claude_post_edit "$reminder" ;;
    claude:stop)      emit_claude_stop      "$reminder" ;;
    *)
      warn "unknown runtime/event: $runtime/$event; staying quiet"
      exit 0
      ;;
  esac
  exit 0
}

# ---------- arg parsing ----------------------------------------------------

usage() {
  cat >&2 <<'USAGE'
usage:
  scripts/docs-check.sh --mode lint
  scripts/docs-check.sh --mode hook --runtime <cursor|codex|claude> \
                                   --event   <post-edit|stop>
USAGE
  exit 64
}

MODE=""
RUNTIME=""
EVENT=""

while [ $# -gt 0 ]; do
  case "$1" in
    --mode)    MODE=${2:-};    shift 2 ;;
    --runtime) RUNTIME=${2:-}; shift 2 ;;
    --event)   EVENT=${2:-};   shift 2 ;;
    -h|--help) usage ;;
    *) usage ;;
  esac
done

case "$MODE" in
  lint) run_lint ;;
  hook)
    [ -z "$RUNTIME" ] && usage
    [ -z "$EVENT" ]   && usage
    run_hook "$RUNTIME" "$EVENT"
    ;;
  *) usage ;;
esac
