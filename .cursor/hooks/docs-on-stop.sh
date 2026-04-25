#!/usr/bin/env bash
# Cursor stop hook: forwards to the shared docs-check entry point.
# `loop_limit: 1` in .cursor/hooks.json prevents the followup_message from
# triggering more than one extra turn.

set -uo pipefail

ROOT=$(git rev-parse --show-toplevel 2>/dev/null) || exit 0
exec bash "$ROOT/scripts/docs-check.sh" \
  --mode hook --runtime cursor --event stop
