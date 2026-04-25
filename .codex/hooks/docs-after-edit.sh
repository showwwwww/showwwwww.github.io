#!/usr/bin/env bash
# Codex PostToolUse hook (matcher: apply_patch|Edit|Write). Forwards to the
# shared docs-check entry point. Codex sends a JSON payload on stdin; we
# pass it through unchanged so docs-check.sh can read stop_hook_active and
# similar fields.

set -uo pipefail

ROOT=$(git rev-parse --show-toplevel 2>/dev/null) || exit 0
exec bash "$ROOT/scripts/docs-check.sh" \
  --mode hook --runtime codex --event post-edit
