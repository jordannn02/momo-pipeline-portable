#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MODE="bundle"
CODEX_BIN="${CODEX_BIN:-codex}"
CLAUDE_BIN="${CLAUDE_BIN:-claude}"
EXPECTED_TEMPLATE_SHA="275433f3d152a509e1f63a4c565cfb9977afde944c40fb2270a7b743705749e0"

usage() {
  cat <<'USAGE'
Usage:
  ./verify.sh --bundle-only
  ./verify.sh --codex
  ./verify.sh --claude
  ./verify.sh --both
  ./verify.sh --runtime
USAGE
}

if [ "$#" -gt 1 ]; then
  usage >&2
  exit 2
fi

case "${1:---bundle-only}" in
  --bundle-only) MODE="bundle" ;;
  --codex) MODE="codex" ;;
  --claude) MODE="claude" ;;
  --both) MODE="both" ;;
  --runtime) MODE="runtime" ;;
  -h|--help)
    usage
    exit 0
    ;;
  *)
    usage >&2
    exit 2
    ;;
esac

ok() { echo "OK   $*"; }
fail() { echo "FAIL $*" >&2; exit 1; }

sha256_file() {
  if command -v shasum >/dev/null 2>&1; then
    shasum -a 256 "$1" | awk '{print $1}'
  elif command -v sha256sum >/dev/null 2>&1; then
    sha256sum "$1" | awk '{print $1}'
  else
    fail "no SHA-256 utility found"
  fi
}

validate_json() {
  if command -v python3 >/dev/null 2>&1; then
    python3 -m json.tool "$1" >/dev/null
  elif command -v node >/dev/null 2>&1; then
    node -e 'JSON.parse(require("fs").readFileSync(process.argv[1], "utf8"))' "$1"
  else
    fail "python3 or node is required for JSON validation"
  fi
}

verify_bundle() {
  local required=(
    "$ROOT/.agents/plugins/marketplace.json"
    "$ROOT/.claude-plugin/marketplace.json"
    "$ROOT/plugins/momo-pipeline/.codex-plugin/plugin.json"
    "$ROOT/plugins/momo-pipeline/.claude-plugin/plugin.json"
    "$ROOT/plugins/momo-pipeline/skills/momo-pipeline/SKILL.md"
    "$ROOT/plugins/momo-pipeline/skills/apply-comments/SKILL.md"
    "$ROOT/plugins/momo-pipeline/assets/templates/PPT模板.pptx"
    "$ROOT/install.sh"
    "$ROOT/uninstall.sh"
  )
  local path
  for path in "${required[@]}"; do
    [ -f "$path" ] || fail "missing $path"
  done
  ok "required bundle files present"

  validate_json "$ROOT/.agents/plugins/marketplace.json"
  validate_json "$ROOT/.claude-plugin/marketplace.json"
  validate_json "$ROOT/plugins/momo-pipeline/.codex-plugin/plugin.json"
  validate_json "$ROOT/plugins/momo-pipeline/.claude-plugin/plugin.json"
  ok "marketplace and plugin JSON valid"

  local actual_sha
  actual_sha="$(sha256_file "$ROOT/plugins/momo-pipeline/assets/templates/PPT模板.pptx")"
  [ "$actual_sha" = "$EXPECTED_TEMPLATE_SHA" ] || fail "Dingxin template checksum mismatch: $actual_sha"
  ok "Dingxin template checksum $actual_sha"

  grep -q "Intake confirmation gate" "$ROOT/plugins/momo-pipeline/skills/momo-pipeline/SKILL.md" || fail "intake hard gate missing"
  grep -q "Template priority" "$ROOT/plugins/momo-pipeline/skills/momo-pipeline/SKILL.md" || fail "template priority missing"
  grep -q "Do not create the final PPTX during Phase 2" "$ROOT/plugins/momo-pipeline/skills/momo-pipeline/SKILL.md" || fail "preview-before-export gate missing"
  grep -q "Adding a comment does \*\*not\*\* wake" "$ROOT/plugins/momo-pipeline/skills/momo-pipeline/SKILL.md" || fail "comment activation boundary missing"
  grep -q "prompt_cache_retention" "$ROOT/plugins/momo-pipeline/skills/momo-pipeline/SKILL.md" || fail "prompt cache boundary missing"
  grep -q "momo_safe_tmpdir" "$ROOT/plugins/momo-pipeline/scripts/runtime-env.sh" || fail "TMPDIR fallback missing"
  ok "workflow contract markers present"

  if [ -f "$ROOT/SHA256SUMS" ]; then
    ok "SHA256SUMS present"
  else
    echo "WARN SHA256SUMS not generated yet"
  fi
}

verify_codex() {
  command -v "$CODEX_BIN" >/dev/null 2>&1 || [ -x "$CODEX_BIN" ] || fail "Codex CLI not found"
  local listing
  listing="$("$CODEX_BIN" plugin list --json)"
  printf '%s' "$listing" | grep -q 'momo-pipeline' || fail "momo-pipeline not listed in Codex"
  ok "Codex lists momo-pipeline"
}

verify_claude() {
  command -v "$CLAUDE_BIN" >/dev/null 2>&1 || [ -x "$CLAUDE_BIN" ] || fail "Claude Code CLI not found"
  local listing
  listing="$("$CLAUDE_BIN" plugin list)"
  printf '%s' "$listing" | grep -q 'momo-pipeline' || fail "momo-pipeline not listed in Claude Code"
  ok "Claude Code lists momo-pipeline"
}

verify_runtime() {
  "$ROOT/plugins/momo-pipeline/scripts/check-env.sh"
  ok "Momo Pipeline runtime ready"
}

verify_bundle

case "$MODE" in
  bundle) ;;
  codex) verify_codex ;;
  claude) verify_claude ;;
  both)
    verify_codex
    verify_claude
    ;;
  runtime) verify_runtime ;;
esac

echo "verification=passed mode=$MODE"
