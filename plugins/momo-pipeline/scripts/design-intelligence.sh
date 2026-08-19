#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'USAGE'
Usage:
  ./scripts/design-intelligence.sh "<deck brief>" [--kind data|pitch|erp|general] [--project "Project Name"]

Purpose:
  Run optional UI/UX Pro Max lookups for PPT Design Studio.

Examples:
  ./scripts/design-intelligence.sh "executive financial dashboard deck" --kind data
  ./scripts/design-intelligence.sh "AI product sales pitch" --kind pitch --project "AI Sales Deck"
  ./scripts/design-intelligence.sh "T100 ERP cost reconciliation report" --kind erp
USAGE
}

if [ "$#" -lt 1 ]; then
  usage >&2
  exit 2
fi

QUERY="$1"
shift

KIND="general"
PROJECT=""

while [ "$#" -gt 0 ]; do
  case "$1" in
    --kind)
      [ "$#" -ge 2 ] || { echo "--kind requires a value" >&2; exit 2; }
      KIND="$2"
      shift 2
      ;;
    --project|-p)
      [ "$#" -ge 2 ] || { echo "--project requires a value" >&2; exit 2; }
      PROJECT="$2"
      shift 2
      ;;
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
done

CODEX_HOME_VALUE="${CODEX_HOME:-$HOME/.codex}"
CLAUDE_HOME_VALUE="${CLAUDE_CONFIG_DIR:-$HOME/.claude}"
SEARCH=""

for candidate in \
  "$HOME/.agents/skills/ui-ux-pro-max/scripts/search.py" \
  "$CODEX_HOME_VALUE/skills/ui-ux-pro-max/scripts/search.py" \
  "$CLAUDE_HOME_VALUE/skills/ui-ux-pro-max/scripts/search.py"; do
  if [ -f "$candidate" ]; then
    SEARCH="$candidate"
    break
  fi
done

if [ -z "$SEARCH" ]; then
  cat <<EOF
status=optional-missing
skill=ui-ux-pro-max
message=UI/UX Pro Max is not installed. Continue with native PPT Design Studio reasoning.
install_hint=npx -y ui-ux-pro-max-cli init --ai codex --global --offline
EOF
  exit 0
fi

PYTHON_BIN="${PYTHON_BIN:-python3}"

run_domain() {
  local domain="$1"
  local q="$2"
  echo ""
  echo "## domain=$domain"
  "$PYTHON_BIN" "$SEARCH" "$q" --domain "$domain" --max-results 3 || true
}

run_design_system() {
  local q="$1"
  local project="${2:-}"
  echo ""
  echo "## design-system"
  if [ -n "$project" ]; then
    "$PYTHON_BIN" "$SEARCH" "$q" --design-system -p "$project" || true
  else
    "$PYTHON_BIN" "$SEARCH" "$q" --design-system || true
  fi
}

echo "# Momo Design Intelligence"
echo ""
echo "- query: $QUERY"
echo "- kind: $KIND"
echo "- source: ui-ux-pro-max"

case "$KIND" in
  data)
    run_domain chart "$QUERY"
    run_domain ux "$QUERY data visualization dashboard accessibility"
    run_domain typography "$QUERY executive business presentation"
    ;;
  pitch)
    run_design_system "$QUERY" "$PROJECT"
    run_domain landing "$QUERY pitch deck story conversion"
    run_domain style "$QUERY premium presentation"
    run_domain color "$QUERY presentation palette"
    run_domain typography "$QUERY pitch deck"
    ;;
  erp)
    run_domain chart "$QUERY KPI table reconciliation variance dashboard"
    run_domain ux "$QUERY enterprise internal operation dense data accessibility"
    run_domain typography "$QUERY enterprise business Chinese presentation"
    run_domain style "$QUERY enterprise dashboard restrained"
    ;;
  general)
    run_domain chart "$QUERY presentation"
    run_domain ux "$QUERY presentation"
    run_domain typography "$QUERY presentation"
    run_domain style "$QUERY presentation"
    ;;
  *)
    echo "Unknown kind: $KIND" >&2
    usage >&2
    exit 2
    ;;
esac
