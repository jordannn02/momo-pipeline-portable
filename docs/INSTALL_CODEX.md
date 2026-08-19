# Codex 安裝說明

## 系統需求

- 可執行的 `codex` CLI，且包含 `codex plugin` 指令。
- Git、Node.js、npm。
- Python 3（PPTX 清理與轉檔）；Python 3.10+ 才安裝可選 MarkItDown。

## 建議安裝

在解壓後的 bundle 根目錄執行：

```bash
./install.sh --codex
```

這會依序執行：

```bash
codex plugin marketplace add /absolute/path/to/momo-pipeline-distribution
codex plugin add momo-pipeline@momo-pipeline-local
```

Codex 會把 marketplace 外掛安裝到自己的快取並管理啟用狀態。安裝後
開新工作階段，再於 Plugins 選取 `Momo Pipeline` 或在提示中使用
`@momo-pipeline`。

## 僅登錄外掛

若網路受限或想稍後才裝工具鏈：

```bash
./install.sh --codex --skip-deps
```

之後執行：

```bash
./plugins/momo-pipeline/scripts/install.sh
./plugins/momo-pipeline/scripts/check-env.sh
```

## 驗證

```bash
./verify.sh --codex
```

也可手動檢查：

```bash
codex plugin marketplace list
codex plugin list
```

## 解除安裝

```bash
./uninstall.sh --codex
```

要一併移除 marketplace 註冊：

```bash
./uninstall.sh --codex --remove-marketplace
```

若要回收 runtime，先做可逆隔離：

```bash
./uninstall.sh --codex --quarantine-runtime
```

## Codex IDE extension 邊界

OpenAI 目前的 Plugins 文件指出 Codex IDE extension 不支援 plugin
browser。請使用 ChatGPT desktop app 或 Codex CLI 完成外掛安裝；單獨的
repo/user skill 則仍可依 Codex skill 位置規則使用。
