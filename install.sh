#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PLUGIN_SELECTOR="momo-pipeline@momo-pipeline-local"
TARGET=""
INSTALL_DEPS="true"
DRY_RUN="false"
CODEX_BIN="${CODEX_BIN:-codex}"
CLAUDE_BIN="${CLAUDE_BIN:-claude}"

usage() {
  cat <<'USAGE'
Usage:
  ./install.sh --codex [--skip-deps] [--dry-run]
  ./install.sh --claude [--skip-deps] [--dry-run]
  ./install.sh --both [--skip-deps] [--dry-run]

Options:
  --codex       Register the local marketplace and install in Codex.
  --claude      Register the local marketplace and install in Claude Code.
  --both        Install in both hosts after checking both CLIs exist.
  --skip-deps   Skip the open-slide, baoyu-design, and Python runtime install.
  --dry-run     Print commands without changing host configuration.

Environment:
  CODEX_HOME          Isolates Codex configuration for testing.
  CLAUDE_CONFIG_DIR   Isolates Claude Code configuration for testing.
  MOMO_PIPELINE_HOME  Runtime dependency root; default is ~/.momo-pipeline.
  CODEX_BIN           Alternate Codex executable.
  CLAUDE_BIN          Alternate Claude Code executable.
USAGE
}

set_target() {
  if [ -n "$TARGET" ]; then
    echo "Choose exactly one of --codex, --claude, or --both." >&2
    exit 2
  fi
  TARGET="$1"
}

while [ "$#" -gt 0 ]; do
  case "$1" in
    --codex) set_target codex ;;
    --claude) set_target claude ;;
    --both) set_target both ;;
    --skip-deps) INSTALL_DEPS="false" ;;
    --dry-run) DRY_RUN="true" ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "Unknown argument: $1" >&2
      usage >&2
      exit 2
      ;;
  esac
  shift
done

if [ -z "$TARGET" ]; then
  echo "Choose --codex, --claude, or --both." >&2
  usage >&2
  exit 2
fi

need_executable() {
  local binary="$1"
  local label="$2"
  if ! command -v "$binary" >/dev/null 2>&1 && [ ! -x "$binary" ]; then
    echo "$label CLI was not found: $binary" >&2
    return 1
  fi
}

run() {
  if [ "$DRY_RUN" = "true" ]; then
    printf 'DRY-RUN'
    printf ' %q' "$@"
    printf '\n'
  else
    "$@"
  fi
}

validate_bundle() {
  local required=(
    "$ROOT/.agents/plugins/marketplace.json"
    "$ROOT/.claude-plugin/marketplace.json"
    "$ROOT/plugins/momo-pipeline/.codex-plugin/plugin.json"
    "$ROOT/plugins/momo-pipeline/.claude-plugin/plugin.json"
    "$ROOT/plugins/momo-pipeline/skills/momo-pipeline/SKILL.md"
    "$ROOT/plugins/momo-pipeline/skills/apply-comments/SKILL.md"
    "$ROOT/plugins/momo-pipeline/assets/templates/PPT模板.pptx"
  )
  local path
  for path in "${required[@]}"; do
    if [ ! -f "$path" ]; then
      echo "Bundle file missing: $path" >&2
      return 1
    fi
  done

  if command -v python3 >/dev/null 2>&1; then
    python3 -m json.tool "$ROOT/.agents/plugins/marketplace.json" >/dev/null
    python3 -m json.tool "$ROOT/.claude-plugin/marketplace.json" >/dev/null
    python3 -m json.tool "$ROOT/plugins/momo-pipeline/.codex-plugin/plugin.json" >/dev/null
    python3 -m json.tool "$ROOT/plugins/momo-pipeline/.claude-plugin/plugin.json" >/dev/null
  fi
}

install_codex() {
  echo "Registering Momo Pipeline marketplace in Codex"
  run "$CODEX_BIN" plugin marketplace add "$ROOT" --json
  echo "Installing $PLUGIN_SELECTOR in Codex"
  run "$CODEX_BIN" plugin add "$PLUGIN_SELECTOR" --json
}

install_claude() {
  echo "Registering Momo Pipeline marketplace in Claude Code"
  run "$CLAUDE_BIN" plugin marketplace add "$ROOT"
  echo "Installing $PLUGIN_SELECTOR in Claude Code user scope"
  run "$CLAUDE_BIN" plugin install "$PLUGIN_SELECTOR" --scope user
}

validate_bundle

case "$TARGET" in
  codex)
    need_executable "$CODEX_BIN" "Codex"
    ;;
  claude)
    need_executable "$CLAUDE_BIN" "Claude Code"
    ;;
  both)
    need_executable "$CODEX_BIN" "Codex"
    need_executable "$CLAUDE_BIN" "Claude Code"
    ;;
esac

case "$TARGET" in
  codex) install_codex ;;
  claude) install_claude ;;
  both)
    install_codex
    install_claude
    ;;
esac

if [ "$INSTALL_DEPS" = "true" ]; then
  echo "Installing shared Momo Pipeline runtime dependencies"
  run "$ROOT/plugins/momo-pipeline/scripts/install.sh"
else
  echo "Skipped runtime dependencies. Install later with:"
  echo "  $ROOT/plugins/momo-pipeline/scripts/install.sh"
fi

cat <<EOF

Momo Pipeline host installation finished.
Version: $(tr -d '\r\n' < "$ROOT/VERSION")

Next:
1. Start a new Codex or Claude Code session, or reload plugins when supported.
2. Invoke Momo Pipeline and ask for a PPT.
3. Confirm the Design Studio intake before preview construction.
4. Add browser component comments, then send /apply-comments.
5. Say "可以輸出" only when the preview is approved.
EOF
