#!/usr/bin/env bash
set -euo pipefail

if [ "$#" -lt 1 ]; then
  cat >&2 <<'USAGE'
Usage: ./scripts/open-preview.sh <preview-url> [--browser safari|chrome|default]

Opens the web slide preview for user-facing review. On macOS, Safari is the
default first choice, with Chrome and the system default browser as fallbacks.
USAGE
  exit 2
fi

URL="$1"
BROWSER="safari"

if [ "${2:-}" = "--browser" ] && [ -n "${3:-}" ]; then
  BROWSER="$3"
fi

open_with_macos() {
  local app="$1"
  if command -v open >/dev/null 2>&1; then
    open -a "$app" "$URL" >/dev/null 2>&1
  else
    return 1
  fi
}

open_default() {
  if command -v open >/dev/null 2>&1; then
    open "$URL" >/dev/null 2>&1
  elif command -v xdg-open >/dev/null 2>&1; then
    xdg-open "$URL" >/dev/null 2>&1
  elif command -v cmd.exe >/dev/null 2>&1; then
    cmd.exe /c start "" "$URL" >/dev/null 2>&1
  else
    echo "No supported browser opener was found; open this URL manually: $URL" >&2
    return 1
  fi
}

case "$BROWSER" in
  safari|Safari)
    open_with_macos "Safari" || open_with_macos "Google Chrome" || open_default
    ;;
  chrome|Chrome|"Google Chrome")
    open_with_macos "Google Chrome" || open_with_macos "Safari" || open_default
    ;;
  default)
    open_default
    ;;
  *)
    echo "Unknown browser: $BROWSER" >&2
    exit 2
    ;;
esac

echo "opened=$URL"
echo "browser_preference=$BROWSER"
