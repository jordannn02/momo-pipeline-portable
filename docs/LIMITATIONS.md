# 已知邊界

- 這是本機/private marketplace bundle，尚未送 OpenAI universal plugin
  directory 或任何公開 marketplace 審核。
- Codex IDE extension 目前不支援 plugin browser；請用 ChatGPT desktop
  app 或 Codex CLI 安裝。
- Claude Code 的 marketplace skill 會加 plugin namespace；open-slide
  workspace 的 project skill 才提供裸 `/apply-comments`。
- Runtime installer 需要網路取得已釘選 revision 的 open-slide、
  baoyu-design，以及 Python 套件。離線時可先 `--skip-deps`，但無法保證
  預覽與 PPTX 匯出完整可用。
- 2026-08-19 的 `npm audit` 顯示 baoyu-design 間接使用的 `image-size`
  對 ICNS、JXL、HEIF parser 有無修補版本可用的 DoS advisory。安裝器已
  升級有修補版的 esbuild；匯出 wrapper 會拒絕在專案內找到的 ICNS、
  JXL、HEIF、HEIC，並要求先轉成 PNG/JPEG。遠端動態資產仍需使用者與
  Agent 自行把關。
- `prompt_cache_retention is not supported on this model` 只能由主機或
  model routing 層修正。Momo Pipeline 不設定該參數，只能安全略過並
  繼續本機簡報工作。
- 這個外掛能規範 preview-before-export，但無法取代使用者對商標、
  圖片授權、機密資料與最終內容的審核。
- 包內含鼎新品牌模板。請只分發給對該模板與商標素材有合法使用權的
  同事或合作對象；本打包作業不構成公開再授權。
- 目前安裝驗證涵蓋 manifest、marketplace、host cache 與技能檔案；
  真正的模型自動觸發品質仍會受主機版本、可用工具、模型與提示影響。
