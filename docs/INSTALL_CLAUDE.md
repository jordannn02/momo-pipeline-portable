# Claude Code 安裝說明

## 系統需求

- 已安裝並完成基本設定的 Claude Code CLI。
- Git、Node.js、npm。
- Python 3（PPTX 清理與轉檔）；Python 3.10+ 才安裝可選 MarkItDown。

## 建議安裝

在解壓後的 bundle 根目錄執行：

```bash
./install.sh --claude
```

這會依序執行：

```bash
claude plugin marketplace add /absolute/path/to/momo-pipeline-distribution
claude plugin install momo-pipeline@momo-pipeline-local --scope user
```

重新啟動 Claude Code，或在已開啟的工作階段依安裝訊息執行
`/reload-plugins`。Marketplace skill 使用 namespace：

```text
/momo-pipeline:momo-pipeline
/momo-pipeline:apply-comments
```

open-slide 專案也會建立 project-level `/apply-comments`，因此簡報網頁
提示中的短指令仍能工作。

## 單次測試，不安裝

Claude Code 官方支援直接載入 plugin directory 或 zip：

```bash
claude --plugin-dir ./plugins/momo-pipeline
claude --plugin-dir ./momo-pipeline-0.3.0.zip
```

這只對該次工作階段生效，適合先驗證再安裝。

## 驗證

```bash
./verify.sh --claude
claude plugin list
```

## 解除安裝

```bash
./uninstall.sh --claude
```

要一併移除 marketplace 註冊：

```bash
./uninstall.sh --claude --remove-marketplace
```

Claude Code 可用 `CLAUDE_CONFIG_DIR` 隔離全部個人設定與外掛。本包的
smoke test 正是利用此官方環境變數，不會修改真實 `~/.claude`。
