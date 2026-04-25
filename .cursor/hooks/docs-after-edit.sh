#!/usr/bin/env bash
# Cursor postToolUse hook: forwards to the shared docs-check entry point.
# Resolves the repo root via git so the script works no matter what cwd
# Cursor invoked us from.

set -uo pipefail

ROOT=$(git rev-parse --show-toplevel 2>/dev/null) || exit 0
exec bash "$ROOT/scripts/docs-check.sh" \
  --mode hook --runtime cursor --event post-edit
