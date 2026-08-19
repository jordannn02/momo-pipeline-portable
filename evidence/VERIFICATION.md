# 驗證證據

本檔將由打包流程記錄實際命令與結果。測試使用隔離的 `CODEX_HOME`、
`CLAUDE_CONFIG_DIR` 與 `MOMO_PIPELINE_HOME`，不修改真實使用者設定。

## 預定驗收

- Bundle JSON、skill、script、template 完整性。
- 新版鼎新模板 SHA-256。
- Codex local marketplace add、plugin add、list、remove。
- Claude Code local marketplace add、plugin install、list、uninstall。
- 無效 `TMPDIR` 回退測試。
- zip 展開後 bundle-only 驗證。

## 實際結果

查證時間：2026-08-19（Asia/Taipei）。

### Bundle 靜態驗證

```text
command: ./verify.sh --bundle-only
result: passed
json: Codex marketplace, Claude marketplace, both plugin manifests valid
template_sha256: 275433f3d152a509e1f63a4c565cfb9977afde944c40fb2270a7b743705749e0
contract: intake gate, template priority, preview gate, apply-comments,
          prompt_cache_retention boundary, TMPDIR fallback all present
```

### Codex 隔離安裝

```text
host_cli: codex-cli 0.148.0-alpha.9
isolation: CODEX_HOME=/private/tmp/momo-pipeline-smoke.../codex-home
command: ./tests/smoke-install.sh --codex
marketplace_add: passed, momo-pipeline-local
plugin_add: passed, momo-pipeline 0.3.0
installed_cache: isolated CODEX_HOME/plugins/cache/.../0.3.0
plugin_list: passed
plugin_remove: passed
marketplace_remove: passed
rerun_idempotency: passed, alreadyAdded=true on second run
```

### Claude Code 隔離安裝

```text
host_cli: @anthropic-ai/claude-code 2.1.235
isolation: CLAUDE_CONFIG_DIR=/private/tmp/momo-pipeline-smoke.../claude-config
command: MOMO_SMOKE_DOWNLOAD_CLAUDE=true ./tests/smoke-install.sh --claude
marketplace_add: passed, momo-pipeline-local
plugin_install_user_scope: passed, momo-pipeline 0.3.0
plugin_list: passed
plugin_uninstall: passed
marketplace_remove: passed
rerun_idempotency: passed, second run reported already installed
```

### Runtime 與錯誤邊界

```text
isolation: MOMO_PIPELINE_HOME=/private/tmp/momo-runtime-full...
open_slide_commit: 2adbe12a8462796f5e3568185cb2cf8f231d605c
baoyu_design_commit: 1a4b5c47581066b96b6c303b9203676d7926cbc4
baoyu_build_cli: passed
baoyu_build_page: passed
python_pptx_import: passed
stale_tmpdir_input: /private/var/folders/momo-pipeline-missing
resolved_tmpdir: /tmp
check_env: passed
unsafe_asset_guard: HEIC test rejected before export
```

### 發行封裝

```text
core_file_checksums: all passed with SHA256SUMS
plugin_zip_structure: both manifests, both skills, scripts, assets present
distribution_zip_extract: passed
distribution_zip_bundle_verify: passed
distribution_zip_internal_checksums: passed
```

### 依賴稽核邊界

完整 isolated runtime 安裝原始上游 lock 時，`npm audit` 顯示 esbuild
moderate 以及 `image-size` ICNS/JXL/HEIF parser 的 high DoS advisory。包內
安裝器把 esbuild 升級至 0.28.2 並成功重建；`image-size` 在查證日沒有
已發布的修補版，因此以匯出前拒絕 ICNS/JXL/HEIF/HEIC 作補償控制，並
在 `docs/LIMITATIONS.md` 明示剩餘風險。
