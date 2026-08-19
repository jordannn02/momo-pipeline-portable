#!/usr/bin/env bash
set -euo pipefail

if [ "$#" -lt 2 ]; then
  cat >&2 <<'USAGE'
Usage: ./scripts/convert-source-to-markdown.sh <source-file> <output.md> [--no-markitdown]

This wrapper intentionally avoids stale global MarkItDown launchers. It uses the
momo-pipeline MarkItDown environment first, then built-in fallbacks.
USAGE
  exit 2
fi

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck source=runtime-env.sh
source "$ROOT/scripts/runtime-env.sh"
MOMO_HOME="$(momo_pipeline_home)"
MARKITDOWN_PY="$MOMO_HOME/tools/markitdown-venv/bin/python"
FALLBACK_PY="$MOMO_HOME/tools/momo-pipeline-venv/bin/python"

if [ -x "$MARKITDOWN_PY" ]; then
  PY="$MARKITDOWN_PY"
elif [ -x "$FALLBACK_PY" ]; then
  PY="$FALLBACK_PY"
elif command -v python3 >/dev/null 2>&1; then
  PY="$(command -v python3)"
else
  echo "No Python interpreter found. Run ./scripts/install.sh first." >&2
  exit 1
fi

exec "$PY" "$ROOT/scripts/convert-source-to-markdown.py" "$@"
