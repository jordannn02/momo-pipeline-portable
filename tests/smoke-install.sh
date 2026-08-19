#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TARGET="${1:---codex}"
KEEP="${KEEP_MOMO_SMOKE_DIR:-false}"
SMOKE_DIR="$(mktemp -d "${TMPDIR:-/tmp}/momo-pipeline-smoke.XXXXXX")"

cleanup() {
  if [ "$KEEP" = "true" ]; then
    echo "smoke_dir_preserved=$SMOKE_DIR"
  else
    rm -rf "$SMOKE_DIR"
  fi
}
trap cleanup EXIT

export CODEX_HOME="$SMOKE_DIR/codex-home"
export CLAUDE_CONFIG_DIR="$SMOKE_DIR/claude-config"
export MOMO_PIPELINE_HOME="$SMOKE_DIR/momo-runtime"
mkdir -p "$CODEX_HOME" "$CLAUDE_CONFIG_DIR" "$MOMO_PIPELINE_HOME"

run_codex() {
  command -v codex >/dev/null 2>&1 || { echo "Codex CLI not found" >&2; exit 1; }
  "$ROOT/install.sh" --codex --skip-deps
  "$ROOT/verify.sh" --codex
  test -f "$CODEX_HOME/config.toml"
  "$ROOT/uninstall.sh" --codex --remove-marketplace
  echo "codex_smoke=passed"
}

run_claude() {
  local claude_bin="${CLAUDE_BIN:-}"
  if [ -z "$claude_bin" ]; then
    if command -v claude >/dev/null 2>&1; then
      claude_bin="$(command -v claude)"
    elif [ "${MOMO_SMOKE_DOWNLOAD_CLAUDE:-false}" = "true" ]; then
      mkdir -p "$SMOKE_DIR/claude-cli"
      npm install --prefix "$SMOKE_DIR/claude-cli" @anthropic-ai/claude-code
      claude_bin="$SMOKE_DIR/claude-cli/node_modules/.bin/claude"
    else
      echo "Claude Code CLI not found. Set MOMO_SMOKE_DOWNLOAD_CLAUDE=true to install it in the isolated smoke directory." >&2
      exit 1
    fi
  fi

  CLAUDE_BIN="$claude_bin" "$ROOT/install.sh" --claude --skip-deps
  CLAUDE_BIN="$claude_bin" "$ROOT/verify.sh" --claude
  CLAUDE_BIN="$claude_bin" "$ROOT/uninstall.sh" --claude --remove-marketplace
  echo "claude_smoke=passed"
}

case "$TARGET" in
  --codex) run_codex ;;
  --claude) run_claude ;;
  --both)
    run_codex
    run_claude
    ;;
  *)
    echo "Usage: ./tests/smoke-install.sh --codex|--claude|--both" >&2
    exit 2
    ;;
esac

echo "smoke_install=passed target=$TARGET"
