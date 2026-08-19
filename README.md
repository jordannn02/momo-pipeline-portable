# Momo Pipeline Portable

Momo Pipeline 是一套給 **Codex 與 Claude Code** 使用的簡報工作流外掛。
它把「先確認設計、再開網頁預覽、用元件留言反覆調整、最後才輸出」變成
可安裝、可驗證的固定流程，降低 Agent 太早產檔或誤解修改位置的機率。

目前版本：`0.3.0`

發行型態：Codex／Claude Code 雙主機本機 marketplace bundle

> [!IMPORTANT]
> 本專案會在安裝時整合 [open-slide](https://github.com/1weiho/open-slide)
> 與 [baoyu-design](https://github.com/JimLiu/baoyu-design)，但不是這兩個
> 上游專案的官方發行版。固定 revision、授權與直接依賴請見
> [UPSTREAMS.md](UPSTREAMS.md)。

> [!CAUTION]
> 包內 `PPT模板.pptx` 含鼎新品牌素材。它**不屬於本專案 MIT 授權範圍**，
> 也沒有因放進此 repository 而取得公開散布或商標授權。只有原本就具備
> 合法使用權的人員可以使用或再分發；詳見 [NOTICE.md](NOTICE.md)。

## 專案特色

- **Design Studio 確認門檻**：開始製作前，Agent 必須先對齊頁數、逐頁
  大綱、2 至 3 個美術方向、文字密度與動畫程度。
- **模板優先級可預期**：使用者明確指定的 PPTX 優先；沒有指定時，才
  使用包內藍色鼎新數智 16:9 模板。
- **Browser-first 預覽**：先建立 localhost 網頁預覽，主要可編輯元件
  使用可讀的 `data-label`，方便在畫面上精準點選。
- **元件級留言**：可對指定標題、卡片、圖片或流程節點留言。按下
  `Add comment` 只會保存留言；回到同一個 Agent 工作階段送出
  `/apply-comments` 後，Agent 才會修改、重建並刷新預覽。
- **匯出核准門檻**：`/apply-comments` 不是輸出授權。只有使用者明確說
  「可以輸出」或「輸出 PPTX」才會產生最終檔案。
- **Codex／Claude Code 共用單一內容來源**：同一份 plugin 同時包含
  `.codex-plugin`、`.claude-plugin` 與兩種 marketplace catalog，避免
  兩套技能日後漂移。
- **可重現的核心工具鏈**：open-slide 與 baoyu-design 使用固定 Git
  commit，open-slide CLI 與 esbuild 使用固定版本；版本表見
  [UPSTREAMS.md](UPSTREAMS.md)。
- **macOS `TMPDIR` 修復**：繼承到已不存在或不可寫的暫存目錄時，自動
  改用可寫的 `/tmp`，避免 build／preview 因 `ENOENT` 中斷。
- **安全與品質邊界**：匯出 wrapper 會拒絕已知有 parser 風險的本機
  ICNS、JXL、HEIF、HEIC 資產；`prompt_cache_retention` 警告也會正確
  歸因到 host／model routing，而不是誤判成簡報流程失敗。

## 10 頁教學一致流程

這個外掛的行為契約與示範教材採用同一條主線：

| 頁次 | 教學內容 | 對應外掛行為 |
| --- | --- | --- |
| 1 | 封面與學習目標 | 明確教 Momo Pipeline，不改成一般 Codex 教學 |
| 2 | 何時適合使用 | 釐清簡報任務與輸入素材 |
| 3 | 四階段總覽 | 對齊設計、建立預覽、套用留言、核准輸出 |
| 4 | 第一段可複製提示 | 明確叫用外掛並說出目標 |
| 5 | Design Studio | 確認頁數、大綱、美術、密度與動畫 |
| 6 | 模板優先順序 | 指定 PPTX 優先，包內模板作為預設 |
| 7 | 實際網頁預覽 | 檢查 16:9 頁面與 `data-label` 元件 |
| 8 | 指定元件調整 | 留言後另送 `/apply-comments`，再看刷新結果 |
| 9 | 輸出核准 | 預覽通過後才說「可以輸出」 |
| 10 | 排錯與重用 | TMPDIR、路由警告與完整啟動提示 |

更細的對照與好留言範例請見
[docs/PPT_TEACHING_FLOW.md](docs/PPT_TEACHING_FLOW.md)。

## 快速安裝

### 從 Release 安裝

下載 `momo-pipeline-distribution-0.3.0.zip`，解壓後在 bundle 根目錄執行：

```bash
./install.sh --codex
./install.sh --claude
./install.sh --both
```

預設會把共用 runtime 安裝到 `~/.momo-pipeline/`。如果只想先驗證外掛
註冊，不下載工具鏈：

```bash
./install.sh --codex --skip-deps
```

### 從此 repository 安裝

```bash
git clone https://github.com/jordannn02/momo-pipeline-portable.git
cd momo-pipeline-portable
./verify.sh --bundle-only
./install.sh --codex     # 或 --claude / --both
```

安裝後請開新工作階段。Codex 可使用 `@momo-pipeline`；Claude Code 的
marketplace skill 使用 `/momo-pipeline:momo-pipeline`。

## 可直接複製的啟動提示

```text
使用 momo-pipeline：用鼎新模板製作一份 10 頁簡報。
請先提出逐頁大綱、2 至 3 種美術方向、文字密度與動畫程度，等我確認。
確認後先開網頁預覽，所有主要元件加 data-label，讓我在畫面上留言。
我送出 /apply-comments 後再套用並刷新；沒有我說「可以輸出」，不要產 PPTX。
```

留言範例：

```text
第 7 頁／右側實際網頁截圖：裁切掉多餘空白，保留留言面板。
第 8 頁／藍色流程卡：寬度增加 15%，標題仍然左對齊。
```

按下 `Add comment` 後，回到同一個 Agent 工作階段送出：

```text
/apply-comments
```

## 驗證

```bash
./verify.sh --bundle-only
./verify.sh --codex
./verify.sh --claude
./verify.sh --runtime

./tests/smoke-install.sh --codex
./tests/smoke-install.sh --claude
./tests/smoke-install.sh --both
```

既有 smoke test 使用隔離的 `CODEX_HOME`、`CLAUDE_CONFIG_DIR` 與
`MOMO_PIPELINE_HOME`，不修改真實使用者設定。實測摘要見
[evidence/VERIFICATION.md](evidence/VERIFICATION.md)。

## 解除安裝與回復

```bash
./uninstall.sh --codex
./uninstall.sh --claude
./uninstall.sh --both
```

預設只移除外掛並保留 runtime。`--quarantine-runtime` 會把 runtime 移到
帶時間戳的同層 quarantine，方便回復，不會永久刪除。

## 文件索引

- [Codex 安裝說明](docs/INSTALL_CODEX.md)
- [Claude Code 安裝說明](docs/INSTALL_CLAUDE.md)
- [10 頁教學流程對照](docs/PPT_TEACHING_FLOW.md)
- [直接上游、固定版本與授權](UPSTREAMS.md)
- [官方主機規格依據](docs/OFFICIAL_REFERENCES.md)
- [已知邊界](docs/LIMITATIONS.md)
- [驗證證據](evidence/VERIFICATION.md)
- [品牌與第三方聲明](NOTICE.md)

## 授權

Momo Pipeline 自有程式碼與原創文件採 MIT License，詳見
[LICENSE](LICENSE)。上游依賴各自適用其原始授權；鼎新品牌模板不在 MIT
授權範圍內。
