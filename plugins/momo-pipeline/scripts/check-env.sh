#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=runtime-env.sh
source "$SCRIPT_DIR/runtime-env.sh"

MOMO_HOME="$(momo_pipeline_home)"
TOOLS_DIR="$MOMO_HOME/tools"
OPEN_SLIDE_REPO="$TOOLS_DIR/open-slide"
BAOYU_CLI="$TOOLS_DIR/baoyu-design/skills/baoyu-design/agents/gen-pptx/dist/cli.mjs"
VENV_PY="$TOOLS_DIR/momo-pipeline-venv/bin/python"
MARKITDOWN_BIN="$TOOLS_DIR/markitdown-venv/bin/markitdown"
PLUGIN_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DESIGN_INTEL_SCRIPT="$PLUGIN_ROOT/scripts/design-intelligence.sh"
CODEX_HOME_VALUE="${CODEX_HOME:-$HOME/.codex}"
CLAUDE_HOME_VALUE="${CLAUDE_CONFIG_DIR:-$HOME/.claude}"
UIUX_SKILL_AGENT="$HOME/.agents/skills/ui-ux-pro-max/SKILL.md"
UIUX_SEARCH_AGENT="$HOME/.agents/skills/ui-ux-pro-max/scripts/search.py"
UIUX_SKILL_CODEX="$CODEX_HOME_VALUE/skills/ui-ux-pro-max/SKILL.md"
UIUX_SEARCH_CODEX="$CODEX_HOME_VALUE/skills/ui-ux-pro-max/scripts/search.py"
UIUX_SKILL_CLAUDE="$CLAUDE_HOME_VALUE/skills/ui-ux-pro-max/SKILL.md"
UIUX_SEARCH_CLAUDE="$CLAUDE_HOME_VALUE/skills/ui-ux-pro-max/scripts/search.py"
TASTE_SKILL_AGENT="$HOME/.agents/skills/design-taste-frontend/SKILL.md"
TASTE_SKILL_CODEX="$CODEX_HOME_VALUE/skills/design-taste-frontend/SKILL.md"
TASTE_SKILL_CLAUDE="$CLAUDE_HOME_VALUE/skills/design-taste-frontend/SKILL.md"
DEFAULT_DINGXIN_TEMPLATE="$PLUGIN_ROOT/assets/templates/PPT模板.pptx"

status=0

ok() { echo "OK   $*"; }
miss() { echo "MISS $*" >&2; status=1; }
opt() { echo "OPT  $*"; }

if SAFE_TMPDIR="$(momo_safe_tmpdir)"; then
  ok "writable temporary directory at $SAFE_TMPDIR"
else
  miss "no writable temporary directory"
fi

if command -v node >/dev/null 2>&1; then
  ok "node $(node -v)"
else
  miss "node not found"
fi

if command -v npm >/dev/null 2>&1; then
  ok "npm $(npm -v)"
else
  miss "npm not found"
fi

if command -v git >/dev/null 2>&1; then
  ok "git $(git --version | awk '{print $3}')"
else
  miss "git not found"
fi

if [ -d "$OPEN_SLIDE_REPO/.git" ]; then
  ok "open-slide repo at $OPEN_SLIDE_REPO"
else
  miss "open-slide repo missing at $OPEN_SLIDE_REPO"
fi

if [ -f "$BAOYU_CLI" ]; then
  ok "baoyu gen-pptx CLI at $BAOYU_CLI"
else
  miss "baoyu gen-pptx CLI missing at $BAOYU_CLI"
fi

if [ -x "$VENV_PY" ]; then
  if "$VENV_PY" - <<'PY' >/dev/null 2>&1
import pptx
import PIL
PY
  then
    ok "Python PPTX helper environment at $VENV_PY"
  else
    miss "Python PPTX helper exists but imports failed at $VENV_PY"
  fi
else
  miss "Python PPTX helper environment missing at $VENV_PY"
fi

if [ -x "$MARKITDOWN_BIN" ]; then
  ok "MarkItDown converter at $MARKITDOWN_BIN"
else
  opt "managed MarkItDown converter missing; built-in source conversion fallbacks remain available"
fi

if [ -x "$PLUGIN_ROOT/scripts/convert-source-to-markdown.sh" ]; then
  ok "source-to-Markdown wrapper at $PLUGIN_ROOT/scripts/convert-source-to-markdown.sh"
else
  miss "source-to-Markdown wrapper missing or not executable"
fi

if [ -x "$PLUGIN_ROOT/scripts/open-preview.sh" ]; then
  ok "browser preview opener at $PLUGIN_ROOT/scripts/open-preview.sh"
else
  miss "browser preview opener missing or not executable"
fi

if [ -x "$DESIGN_INTEL_SCRIPT" ]; then
  ok "design intelligence helper at $DESIGN_INTEL_SCRIPT"
else
  miss "design intelligence helper missing or not executable at $DESIGN_INTEL_SCRIPT"
fi

if [ -f "$DEFAULT_DINGXIN_TEMPLATE" ]; then
  ok "packaged Dingxin template at $DEFAULT_DINGXIN_TEMPLATE"
else
  miss "packaged Dingxin template missing at $DEFAULT_DINGXIN_TEMPLATE"
fi

if [ -f "$UIUX_SKILL_AGENT" ] && [ -f "$UIUX_SEARCH_AGENT" ]; then
  ok "optional ui-ux-pro-max skill at $UIUX_SKILL_AGENT"
elif [ -f "$UIUX_SKILL_CODEX" ] && [ -f "$UIUX_SEARCH_CODEX" ]; then
  ok "optional ui-ux-pro-max skill at $UIUX_SKILL_CODEX"
elif [ -f "$UIUX_SKILL_CLAUDE" ] && [ -f "$UIUX_SEARCH_CLAUDE" ]; then
  ok "optional ui-ux-pro-max skill at $UIUX_SKILL_CLAUDE"
else
  opt "ui-ux-pro-max not installed; install with: npx -y ui-ux-pro-max-cli init --ai codex --global --offline"
fi

if [ -f "$TASTE_SKILL_AGENT" ]; then
  ok "optional taste skill at $TASTE_SKILL_AGENT"
elif [ -f "$TASTE_SKILL_CODEX" ]; then
  ok "optional taste skill at $TASTE_SKILL_CODEX"
elif [ -f "$TASTE_SKILL_CLAUDE" ]; then
  ok "optional taste skill at $TASTE_SKILL_CLAUDE"
else
  opt "design-taste-frontend not installed; install with: npx -y skills add https://github.com/Leonxlnx/taste-skill -g --agent codex --skill '*' -y --copy"
fi

if [ "$status" -eq 0 ]; then
  echo "momo-pipeline environment is ready."
else
  echo "Run the plugin's scripts/install.sh to install missing required dependencies." >&2
fi

exit "$status"
