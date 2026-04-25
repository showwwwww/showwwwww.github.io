#!/usr/bin/env bash
# Claude Code PostToolUse hook (matcher: Edit|Write|MultiEdit). Forwards to
# the shared docs-check entry point. Claude Code sends a JSON payload on
# stdin; we pass it through unchanged.

set -uo pipefail

ROOT=$(git rev-parse --show-toplevel 2>/dev/null) || exit 0
exec bash "$ROOT/scripts/docs-check.sh" \
  --mode hook --runtime claude --event post-edit
