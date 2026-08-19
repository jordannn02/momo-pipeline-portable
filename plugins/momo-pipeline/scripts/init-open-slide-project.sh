#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=runtime-env.sh
source "$SCRIPT_DIR/runtime-env.sh"
SAFE_TMPDIR="$(momo_safe_tmpdir)"

if [ "$#" -ne 1 ]; then
  echo "Usage: ./scripts/init-open-slide-project.sh <workspace-dir>" >&2
  exit 2
fi

PROJECT_DIR="$1"

if [ -e "$PROJECT_DIR" ] && [ -n "$(find "$PROJECT_DIR" -mindepth 1 -maxdepth 1 2>/dev/null)" ]; then
  echo "Workspace already exists and is not empty: $PROJECT_DIR" >&2
  exit 1
fi

mkdir -p "$(dirname "$PROJECT_DIR")"

echo "Initializing open-slide workspace: $PROJECT_DIR"
TMPDIR="$SAFE_TMPDIR" npm exec --yes @open-slide/cli@1.3.2 -- init --use-pnpm --no-install --no-git "$PROJECT_DIR"

(
  cd "$PROJECT_DIR"
  if command -v corepack >/dev/null 2>&1; then
    TMPDIR="$SAFE_TMPDIR" corepack pnpm install
  elif command -v pnpm >/dev/null 2>&1; then
    TMPDIR="$SAFE_TMPDIR" pnpm install
  else
    echo "pnpm/corepack not found. Install dependencies with: corepack pnpm install" >&2
    exit 1
  fi
)

echo "Open-slide workspace ready: $PROJECT_DIR"
echo "Preview command: cd \"$PROJECT_DIR\" && TMPDIR=\"$SAFE_TMPDIR\" corepack pnpm dev"
