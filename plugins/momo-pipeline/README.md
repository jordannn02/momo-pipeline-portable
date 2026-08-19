# Momo Pipeline 0.3.0

Momo Pipeline is a skills-only presentation plugin for Codex and Claude Code.
It guides a deck through design intake, exact-template resolution, browser
preview, component comments, approval-gated export, and final QA.

## Core contract

1. Confirm page count, outline, art direction, density, and motion before slide
   code unless the user explicitly skips the intake.
2. Use an attached or explicitly named PPTX before any packaged or historical
   template.
3. For an unnamed Dingxin request, use
   `assets/templates/PPT模板.pptx` and preserve its blue `鼎新數智` system.
4. Build and open a localhost browser preview before export.
5. Add stable `data-label` values to major editable components.
6. Browser comments do not wake the agent. Apply pending markers only after the
   user sends `/apply-comments` or explicitly asks to apply comments.
7. `/apply-comments` refreshes the preview; it never implies PPTX export
   approval.
8. Export only after an explicit phrase such as `可以輸出` or `輸出 PPTX`.

## Packaged Dingxin template

```text
assets/templates/PPT模板.pptx
```

The packaged file is the current 23-slide, 16:9 blue Dingxin Digital
Intelligence template. An exact user-supplied template still has higher
priority.

## Skills

- `skills/momo-pipeline/SKILL.md`: end-to-end presentation workflow.
- `skills/apply-comments/SKILL.md`: decodes and applies open-slide inspector
  markers, rebuilds the preview, and reports applied/skipped counts.

Claude Code plugin skills are namespaced. Depending on scope, invoke them as
`/momo-pipeline:momo-pipeline` and `/momo-pipeline:apply-comments`. An
open-slide workspace also installs a project-level `/apply-comments` skill.

In Codex or ChatGPT, select or mention `@momo-pipeline`, then describe the deck
task. Installed skill discovery may also expose `$momo-pipeline`.

## Runtime dependencies

The host installer registers the plugin. This plugin script installs the local
slide toolchain under `${MOMO_PIPELINE_HOME:-$HOME/.momo-pipeline}`:

```bash
./scripts/install.sh
./scripts/check-env.sh
```

The installer pins the verified open-slide and baoyu-design revisions and does
not write a global `markitdown` launcher. MarkItDown is optional; built-in
PPTX, DOCX, text, HTML, and CSV conversion fallbacks remain available.

## Recommended prompt

```text
使用 momo-pipeline：用鼎新模板做一份 10 頁教材。
先跟我確認頁數、逐頁大綱、美術方向、文字密度與動畫程度。
確認後開瀏覽器預覽，讓我用元件留言調整；沒有我明確說可以輸出，
不要產 PPTX。
```

## Component comment loop

1. In the browser preview, select the labelled component.
2. Add a concise change request, such as `右側藍色卡片放大 15%`.
3. Return to the agent and send `/apply-comments`.
4. The agent reads `@slide-comment` markers, edits only the requested
   components, removes applied markers, rebuilds, and refreshes the preview.
5. Review again or explicitly approve PPTX export.

## Troubleshooting boundaries

- `prompt_cache_retention is not supported on this model` is a host/model
  routing compatibility warning. Momo Pipeline neither sets nor requires that
  parameter. Continue the local deck workflow without it when the host allows.
- A stale macOS `TMPDIR` is retried with a validated `/tmp` fallback.
- Adding an inspector comment alone does not run the agent. Send
  `/apply-comments` in the active task.
- If comments remove a page while the approved page count is fixed, preserve
  the total unless the user explicitly changes it.

## Included scripts

- `scripts/install.sh`: install pinned runtime dependencies.
- `scripts/check-env.sh`: verify runtime, template, and optional skills.
- `scripts/init-open-slide-project.sh`: scaffold a preview workspace.
- `scripts/open-preview.sh`: open the localhost preview cross-platform.
- `scripts/export-html-to-pptx.sh`: export through baoyu-design after approval.
- `scripts/convert-source-to-markdown.sh`: managed conversion wrapper.
- `scripts/cleanup-pptx-placeholders.py`: remove unused prompt placeholders.

For host registration, use the distribution bundle's top-level `install.sh`
and the Codex/Claude installation guides shipped beside it.
