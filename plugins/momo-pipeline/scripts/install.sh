#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=runtime-env.sh
source "$SCRIPT_DIR/runtime-env.sh"

MOMO_HOME="$(momo_pipeline_home)"
TOOLS_DIR="$MOMO_HOME/tools"
MARKITDOWN_VENV="$TOOLS_DIR/markitdown-venv"
OPEN_SLIDE_REF="2adbe12a8462796f5e3568185cb2cf8f231d605c"
BAOYU_REF="1a4b5c47581066b96b6c303b9203676d7926cbc4"
SKIP_MARKITDOWN="false"
SAFE_TMPDIR="$(momo_safe_tmpdir)"

usage() {
  cat <<'USAGE'
Usage: ./scripts/install.sh [--skip-markitdown]

Installs Momo Pipeline runtime dependencies under:
  ${MOMO_PIPELINE_HOME:-$HOME/.momo-pipeline}/tools

This script does not install or enable the host plugin. Use the distribution
bundle's top-level install.sh for Codex or Claude Code registration.
USAGE
}

for arg in "$@"; do
  case "$arg" in
    --skip-markitdown) SKIP_MARKITDOWN="true" ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "Unknown argument: $arg" >&2
      usage >&2
      exit 2
      ;;
  esac
done

need_cmd() {
  if ! command -v "$1" >/dev/null 2>&1; then
    echo "Missing required command: $1" >&2
    return 1
  fi
}

ensure_repo_at_ref() {
  local name="$1"
  local url="$2"
  local dir="$3"
  local ref="$4"

  mkdir -p "$(dirname "$dir")"
  if [ -e "$dir" ] && [ ! -d "$dir/.git" ]; then
    echo "Refusing to replace non-Git path: $dir" >&2
    return 1
  fi

  if [ ! -d "$dir/.git" ]; then
    echo "Cloning $name into $dir"
    TMPDIR="$SAFE_TMPDIR" git clone --filter=blob:none --no-checkout "$url" "$dir"
  fi

  echo "Pinning $name at $ref"
  TMPDIR="$SAFE_TMPDIR" git -C "$dir" fetch --depth 1 origin "$ref"
  git -C "$dir" checkout --detach "$ref"
}

python_version_ok() {
  "$1" - <<'PY' >/dev/null 2>&1
import sys
raise SystemExit(0 if sys.version_info >= (3, 10) else 1)
PY
}

find_markitdown_python() {
  if [ -n "${MARKITDOWN_PYTHON:-}" ] && command -v "$MARKITDOWN_PYTHON" >/dev/null 2>&1 && python_version_ok "$MARKITDOWN_PYTHON"; then
    command -v "$MARKITDOWN_PYTHON"
    return 0
  fi

  local candidates=(python3.13 python3.12 python3.11 python3.10 python3)
  local candidate
  for candidate in "${candidates[@]}"; do
    if command -v "$candidate" >/dev/null 2>&1; then
      local resolved
      resolved="$(command -v "$candidate")"
      if python_version_ok "$resolved"; then
        echo "$resolved"
        return 0
      fi
    fi
  done

  return 1
}

echo "Installing Momo Pipeline runtime dependencies"
echo "MOMO_PIPELINE_HOME=$MOMO_HOME"
need_cmd git
need_cmd node
need_cmd npm

mkdir -p "$TOOLS_DIR"
ensure_repo_at_ref "open-slide" "https://github.com/1weiho/open-slide.git" "$TOOLS_DIR/open-slide" "$OPEN_SLIDE_REF"
ensure_repo_at_ref "baoyu-design" "https://github.com/jimliu/baoyu-design.git" "$TOOLS_DIR/baoyu-design" "$BAOYU_REF"

if command -v corepack >/dev/null 2>&1; then
  corepack enable >/dev/null 2>&1 || true
fi

BAOYU_GEN="$TOOLS_DIR/baoyu-design/skills/baoyu-design/agents/gen-pptx"
if [ ! -f "$BAOYU_GEN/package.json" ]; then
  echo "baoyu gen-pptx package not found at $BAOYU_GEN" >&2
  exit 1
fi

echo "Building baoyu-design gen-pptx exporter"
(
  cd "$BAOYU_GEN"
  TMPDIR="$SAFE_TMPDIR" npm ci || TMPDIR="$SAFE_TMPDIR" npm install
  # The pinned exporter declares an esbuild range with a known development
  # server advisory. Momo uses esbuild only to bundle the CLI, but install a
  # fixed build version so the local toolchain does not retain that advisory.
  TMPDIR="$SAFE_TMPDIR" npm install --save-dev --save-exact esbuild@0.28.2
  TMPDIR="$SAFE_TMPDIR" npm run build:cli
  TMPDIR="$SAFE_TMPDIR" npm run build:page || true
)

PYTHON_BIN="${PYTHON:-python3}"
VENV="$TOOLS_DIR/momo-pipeline-venv"
if command -v "$PYTHON_BIN" >/dev/null 2>&1; then
  echo "Preparing Python helper environment at $VENV"
  "$PYTHON_BIN" -m venv "$VENV"
  TMPDIR="$SAFE_TMPDIR" "$VENV/bin/python" -m pip install --upgrade pip
  TMPDIR="$SAFE_TMPDIR" "$VENV/bin/python" -m pip install python-pptx pillow
else
  echo "python3 is required for PPTX cleanup and source conversion." >&2
  exit 1
fi

if [ "$SKIP_MARKITDOWN" = "false" ] && MARKITDOWN_PY="$(find_markitdown_python)"; then
  echo "Preparing optional MarkItDown environment at $MARKITDOWN_VENV"
  "$MARKITDOWN_PY" -m venv "$MARKITDOWN_VENV"
  TMPDIR="$SAFE_TMPDIR" "$MARKITDOWN_VENV/bin/python" -m pip install --upgrade pip
  TMPDIR="$SAFE_TMPDIR" "$MARKITDOWN_VENV/bin/python" -m pip install "markitdown[all]"
else
  echo "Skipping optional MarkItDown; built-in conversion fallbacks remain available."
fi

echo "Runtime install complete."
echo "Security boundary: convert untrusted ICNS, JXL, HEIF, and HEIC assets to PNG or JPEG before export."
echo "Run: $SCRIPT_DIR/check-env.sh"
