# Changelog

## 0.3.0 - 2026-08-19

- Added dual Codex and Claude Code manifests and local marketplace catalogs.
- Added one-command install, verify, smoke-test, and reversible uninstall flows.
- Packaged the exact current blue Dingxin `PPT模板.pptx`.
- Enforced the intake hard gate for page count, outline, art direction, density,
  and motion.
- Preserved exact-template priority and preview-before-export approval gate.
- Added `apply-comments` skill, component `data-label` guidance, and the rule
  that browser comments run only after `/apply-comments`.
- Made runtime storage host-neutral through `MOMO_PIPELINE_HOME`.
- Kept safe `TMPDIR` fallback and documented the unsupported
  `prompt_cache_retention` routing boundary.
- Pinned verified open-slide and baoyu-design revisions plus open-slide CLI.
- Upgraded the runtime build esbuild to a fixed version and blocked local
  ICNS/JXL/HEIF/HEIC assets before export due to the current upstream
  image-size parser advisory.
