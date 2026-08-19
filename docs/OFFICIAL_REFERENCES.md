# 官方規格依據

查證日期：2026-08-19。以下只列官方文件。

## OpenAI / Codex

- [Build skills](https://developers.openai.com/codex/skills)
  - `SKILL.md` 必須包含 `name` 與 `description`。
  - Codex user skills 位於 `$HOME/.agents/skills`。
  - 可重用分發應使用 plugins。
- [Build plugins](https://learn.chatgpt.com/docs/build-plugins)
  - Skills-only plugin 使用 `.codex-plugin/plugin.json` 與 `skills/`。
  - 建議先以 local marketplace 安裝並在新對話測試。
- [Package your plugin](https://developers.openai.com/plugins/build/plugins)
  - Repo marketplace 位於 `.agents/plugins/marketplace.json`。
  - `source.path` 使用相對 marketplace root 的 `./` 路徑。
  - `codex plugin marketplace add` 可註冊本機或 Git marketplace。
  - Plugin 安裝後載入的是 host cache，不是直接執行來源目錄。
- [Use plugins](https://developers.openai.com/codex/plugins)
  - Codex CLI 以 `/plugins` 管理外掛，安裝後應開新工作階段。
  - IDE extension 目前不支援 plugins。

## Anthropic / Claude Code

- [Extend Claude with skills](https://code.claude.com/docs/en/slash-commands)
  - Personal skills 位於 `~/.claude/skills/<name>/SKILL.md`。
  - Plugin skills 位於 `<plugin>/skills/<name>/SKILL.md` 並使用 namespace。
  - `${CLAUDE_SKILL_DIR}` 可定位技能隨附腳本。
- [Create plugins](https://code.claude.com/docs/en/plugins)
  - `.claude-plugin/plugin.json` 位於 plugin root 下的 manifest 目錄。
  - `skills/`、`scripts/`、assets 必須在 plugin root，而非 manifest 目錄內。
  - `claude --plugin-dir` 可載入資料夾或 zip 做單次測試。
- [Create and distribute a plugin marketplace](https://code.claude.com/docs/en/plugin-marketplaces)
  - `.claude-plugin/marketplace.json` 可列出 local plugin source。
  - Claude Code 會將 marketplace plugin 複製到自己的 cache。
- [Discover and install plugins](https://code.claude.com/docs/en/discover-plugins)
  - `claude plugin install ... --scope user` 可非互動安裝。
  - `/reload-plugins` 或新工作階段使安裝內容生效。
- [Environment variables](https://code.claude.com/docs/en/env-vars)
  - `CLAUDE_CONFIG_DIR` 可完整隔離 Claude Code 的設定、歷史與 plugins。

## 實作選擇

本包同時放置 `.codex-plugin/plugin.json` 與
`.claude-plugin/plugin.json`，並為兩個主機提供各自官方 marketplace
catalog。實際技能、腳本與模板只有一份，避免兩份內容日後漂移。
