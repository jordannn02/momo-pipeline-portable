#!/usr/bin/env bash

# Shared runtime helpers for macOS desktop sessions.

momo_safe_tmpdir() {
  local candidate="${TMPDIR:-${TEMP:-/tmp}}"

  if [ ! -d "$candidate" ] || [ ! -w "$candidate" ]; then
    candidate="/tmp"
  fi

  if [ ! -d "$candidate" ] || [ ! -w "$candidate" ]; then
    echo "No writable temporary directory is available." >&2
    return 1
  fi

  printf '%s\n' "$candidate"
}

momo_pipeline_home() {
  local candidate="${MOMO_PIPELINE_HOME:-$HOME/.momo-pipeline}"

  if [ -z "$candidate" ]; then
    echo "MOMO_PIPELINE_HOME resolved to an empty path." >&2
    return 1
  fi

  printf '%s\n' "$candidate"
}
