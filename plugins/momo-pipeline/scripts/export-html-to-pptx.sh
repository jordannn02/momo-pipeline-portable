#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=runtime-env.sh
source "$SCRIPT_DIR/runtime-env.sh"
SAFE_TMPDIR="$(momo_safe_tmpdir)"

if [ "$#" -lt 3 ]; then
  cat >&2 <<'USAGE'
Usage: ./scripts/export-html-to-pptx.sh <served-deck-url> <config-json|-> <out-dir>

Example:
  ./scripts/export-html-to-pptx.sh http://localhost:5173/deck ./export-config.json outputs
USAGE
  exit 2
fi

URL="$1"
CONFIG="$2"
OUT_DIR="$3"

ASSET_ROOT="${MOMO_ASSET_ROOT:-$PWD}"
if [ -d "$ASSET_ROOT" ]; then
  UNSAFE_ASSET="$(find "$ASSET_ROOT" \
    \( -name node_modules -o -name .git -o -name dist \) -prune -o \
    -type f \( -iname '*.icns' -o -iname '*.jxl' -o -iname '*.heif' -o -iname '*.heic' \) \
    -print -quit 2>/dev/null || true)"
  if [ -n "$UNSAFE_ASSET" ]; then
    echo "Refusing to export an asset format affected by the current image-size parser advisory: $UNSAFE_ASSET" >&2
    echo "Convert it to PNG or JPEG, then retry." >&2
    exit 1
  fi
fi

MOMO_HOME="$(momo_pipeline_home)"
CODEX_HOME_VALUE="${CODEX_HOME:-$HOME/.codex}"
TOOLS_CLI="$MOMO_HOME/tools/baoyu-design/skills/baoyu-design/agents/gen-pptx/dist/cli.mjs"
SKILL_CLI="$CODEX_HOME_VALUE/skills/baoyu-design/agents/gen-pptx/dist/cli.mjs"

if [ -f "$TOOLS_CLI" ]; then
  CLI="$TOOLS_CLI"
elif [ -f "$SKILL_CLI" ]; then
  CLI="$SKILL_CLI"
else
  echo "baoyu-design gen-pptx CLI not found." >&2
  echo "Run ./scripts/install.sh first." >&2
  exit 1
fi

mkdir -p "$OUT_DIR"
TMPDIR="$SAFE_TMPDIR" node "$CLI" --url "$URL" --config "$CONFIG" --out "$OUT_DIR"
