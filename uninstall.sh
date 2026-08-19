#!/usr/bin/env bash
set -euo pipefail

PLUGIN_SELECTOR="momo-pipeline@momo-pipeline-local"
MARKETPLACE="momo-pipeline-local"
TARGET=""
REMOVE_MARKETPLACE="false"
QUARANTINE_RUNTIME="false"
CODEX_BIN="${CODEX_BIN:-codex}"
CLAUDE_BIN="${CLAUDE_BIN:-claude}"

usage() {
  cat <<'USAGE'
Usage:
  ./uninstall.sh --codex [--remove-marketplace] [--quarantine-runtime]
  ./uninstall.sh --claude [--remove-marketplace] [--quarantine-runtime]
  ./uninstall.sh --both [--remove-marketplace] [--quarantine-runtime]

By default only the installed plugin is removed. Runtime tools are preserved.
--quarantine-runtime moves the exact Momo runtime folder to a timestamped
sibling instead of deleting it.
USAGE
}

set_target() {
  if [ -n "$TARGET" ]; then
    echo "Choose exactly one target." >&2
    exit 2
  fi
  TARGET="$1"
}

while [ "$#" -gt 0 ]; do
  case "$1" in
    --codex) set_target codex ;;
    --claude) set_target claude ;;
    --both) set_target both ;;
    --remove-marketplace) REMOVE_MARKETPLACE="true" ;;
    --quarantine-runtime) QUARANTINE_RUNTIME="true" ;;
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
  usage >&2
  exit 2
fi

remove_codex() {
  "$CODEX_BIN" plugin remove "$PLUGIN_SELECTOR" --json
  if [ "$REMOVE_MARKETPLACE" = "true" ]; then
    "$CODEX_BIN" plugin marketplace remove "$MARKETPLACE" --json
  fi
}

remove_claude() {
  "$CLAUDE_BIN" plugin uninstall "$PLUGIN_SELECTOR" --scope user
  if [ "$REMOVE_MARKETPLACE" = "true" ]; then
    "$CLAUDE_BIN" plugin marketplace remove "$MARKETPLACE"
  fi
}

case "$TARGET" in
  codex) remove_codex ;;
  claude) remove_claude ;;
  both)
    remove_codex
    remove_claude
    ;;
esac

if [ "$QUARANTINE_RUNTIME" = "true" ]; then
  RUNTIME="${MOMO_PIPELINE_HOME:-$HOME/.momo-pipeline}"
  EXPECTED_DEFAULT="$HOME/.momo-pipeline"
  if [ "$RUNTIME" != "$EXPECTED_DEFAULT" ] && [ -z "${MOMO_PIPELINE_HOME:-}" ]; then
    echo "Runtime path validation failed: $RUNTIME" >&2
    exit 1
  fi
  if [ -d "$RUNTIME" ]; then
    STAMP="$(date +%Y%m%d-%H%M%S)"
    QUARANTINE="${RUNTIME}.quarantine-$STAMP"
    mv "$RUNTIME" "$QUARANTINE"
    echo "Runtime moved to: $QUARANTINE"
  else
    echo "Runtime directory not present: $RUNTIME"
  fi
fi

echo "Momo Pipeline uninstall finished."
