#!/usr/bin/env bash
# Claude Code Stop hook. Forwards to the shared docs-check entry point.
# docs-check.sh reads `stop_hook_active` from stdin to avoid looping.

set -uo pipefail

ROOT=$(git rev-parse --show-toplevel 2>/dev/null) || exit 0
exec bash "$ROOT/scripts/docs-check.sh" \
  --mode hook --runtime claude --event stop
