# PPT 教學流程對照

這份契約對應教學簡報，讓不同電腦上的 Agent 做出相同互動。

| 教學重點 | 外掛行為 | 驗收方式 |
| --- | --- | --- |
| 明確叫用 Momo Pipeline | 教的是 Momo Pipeline，不改成通用 Codex 教學 | 大綱含 intake、preview、comment、export |
| 先對設計 | 頁數、大綱、2 至 3 個美術方向、密度、動畫是 hard gate | 未核准前沒有 slide code |
| 鼎新模板 | 明確指定 PPTX 優先；否則用包內藍色鼎新模板 | 比對模板 SHA-256 |
| 瀏覽器預覽 | localhost 16:9 預覽先於 PPTX | 回報 URL 與 workspace |
| 指定元件 | 主要可編輯元件有可讀 `data-label` | Inspector 能選到元件 |
| 留言何時生效 | 新增留言只寫入 `@slide-comment`，不會叫醒 Agent | 使用者另送 `/apply-comments` |
| 套用留言 | 逐項解碼、定位、修改、移除已完成 marker、build、refresh | 回報 applied/skipped |
| 輸出 gate | `/apply-comments` 不等於輸出許可 | 只有明確 `可以輸出` 才產 PPTX |
| TMPDIR | 繼承目錄失效時退回可寫 `/tmp` | 以不存在 TMPDIR 跑 preflight |
| prompt cache 警告 | 當作 host/model routing 邊界，不怪罪 PPT 流程 | 不以相同不支援參數重試 |

## 可複製啟動指令

```text
使用 momo-pipeline：用鼎新模板製作一份 10 頁簡報。
請先提出逐頁大綱、2 至 3 種美術方向、文字密度與動畫程度，等我確認。
確認後先開網頁預覽，所有主要元件加 data-label，讓我在畫面上留言。
我送出 /apply-comments 後再套用並刷新；沒有我說「可以輸出」，不要產 PPTX。
```

## 好的元件留言

```text
第 4 頁／右側流程卡：寬度增加 15%，標題維持左對齊。
第 6 頁／實際網頁截圖：裁切掉網址列以外的空白，保留留言面板。
第 8 頁／比較表第二欄：改用鼎新深藍，文字改白色。
```

## 不足以讓 Agent 動作的操作

只按 `Add comment` 不會啟動 Agent。必須回到同一個 Codex 或 Claude
Code 工作階段，送出 `/apply-comments` 或明確說「套用預覽留言」。
