# 直接上游、固定版本與授權

查證日期：2026-08-19。以下資料是依實際安裝腳本、套件 registry metadata
及官方 repository 回查整理；Momo Pipeline 不主張擁有這些上游專案。

## 固定的核心上游

| 元件 | Momo Pipeline 使用方式 | 固定版本 | 官方來源 | 授權 |
| --- | --- | --- | --- | --- |
| open-slide | 建立 16:9 網頁預覽與可留言工作區 | Git `2adbe12a8462796f5e3568185cb2cf8f231d605c`；CLI `1.3.2` | [1weiho/open-slide](https://github.com/1weiho/open-slide)、[固定 commit](https://github.com/1weiho/open-slide/commit/2adbe12a8462796f5e3568185cb2cf8f231d605c)、[@open-slide/cli 1.3.2](https://www.npmjs.com/package/@open-slide/cli/v/1.3.2) | [MIT](https://github.com/1weiho/open-slide/blob/2adbe12a8462796f5e3568185cb2cf8f231d605c/LICENSE) |
| baoyu-design | HTML 到 PPTX 的 exporter toolchain | Git `1a4b5c47581066b96b6c303b9203676d7926cbc4` | [JimLiu/baoyu-design](https://github.com/JimLiu/baoyu-design)、[固定 commit](https://github.com/JimLiu/baoyu-design/commit/1a4b5c47581066b96b6c303b9203676d7926cbc4) | [MIT](https://github.com/JimLiu/baoyu-design/blob/1a4b5c47581066b96b6c303b9203676d7926cbc4/LICENSE) |
| esbuild | 建置 baoyu-design exporter CLI | npm `0.28.2` | [evanw/esbuild](https://github.com/evanw/esbuild)、[npm 0.28.2](https://www.npmjs.com/package/esbuild/v/0.28.2) | [MIT](https://github.com/evanw/esbuild/blob/v0.28.2/LICENSE.md) |

實際 pin 位於
[`plugins/momo-pipeline/scripts/install.sh`](plugins/momo-pipeline/scripts/install.sh)
與
[`plugins/momo-pipeline/scripts/init-open-slide-project.sh`](plugins/momo-pipeline/scripts/init-open-slide-project.sh)。
版本摘要也記錄於 [`PACKAGE_INFO.json`](PACKAGE_INFO.json)。

查證時另外核對：

- `@open-slide/cli@1.3.2` registry metadata 指向
  `https://github.com/1weiho/open-slide.git`，license 為 MIT。
- open-slide 與 baoyu-design 的固定 commit 都可由 GitHub commit API
  解析，並非僅存在於本機記錄。
- 兩個 Git repository 在查證日都由 GitHub 標示為 public；這不代表
  Momo Pipeline 是其官方套件或受到原作者背書。

## 安裝時解析的 Python 依賴

安裝器目前會從 PyPI 安裝下列套件，**沒有固定 Python 版本**；因此實際
版本會依安裝日期變動。若環境要求完全可重現，應在部署前自行建立並審核
Python constraints／lock file。

| 套件 | 用途 | 官方來源 | Registry 授權資訊 |
| --- | --- | --- | --- |
| python-pptx | PPTX 後處理 | [scanny/python-pptx](https://github.com/scanny/python-pptx)、[PyPI](https://pypi.org/project/python-pptx/) | MIT |
| Pillow | 圖像處理 | [python-pillow/Pillow](https://github.com/python-pillow/Pillow)、[PyPI](https://pypi.org/project/pillow/) | MIT-CMU |
| MarkItDown | 可選的來源文件轉 Markdown | [microsoft/markitdown](https://github.com/microsoft/markitdown)、[PyPI](https://pypi.org/project/markitdown/) | MIT |

Python 套件的授權與 transitive dependencies 仍以實際安裝版本隨附的
metadata／license file 為準。

## 主機規格參考，不是 bundled dependency

Codex 與 Claude Code 的 plugin／skill 安裝格式依各家官方文件實作，詳見
[`docs/OFFICIAL_REFERENCES.md`](docs/OFFICIAL_REFERENCES.md)。這些主機與
文件不是本 repository 重新分發的程式碼。

## 鼎新品牌模板

`plugins/momo-pipeline/assets/templates/PPT模板.pptx` 是使用者提供的品牌
模板，不是上述開源上游，也沒有被本專案重新授予 MIT License。repository
為 private 仍不等於取得再散布權；只有已獲合法授權者可以存取、使用或
分發。詳見 [`NOTICE.md`](NOTICE.md)。
