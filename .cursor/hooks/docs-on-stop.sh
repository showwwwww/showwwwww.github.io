#!/usr/bin/env bash
# Cursor stop hook: forwards to the shared docs-check entry point.
# docs-check.sh de-dupes followup_message output for the same dirty state so
# an ignored reminder cannot become a repeated conversation loop.

set -uo pipefail

ROOT=$(git rev-parse --show-toplevel 2>/dev/null) || exit 0
exec bash "$ROOT/scripts/docs-check.sh" \
  --mode hook --runtime cursor --event stop
