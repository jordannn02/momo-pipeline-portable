---
name: momo-pipeline
description: Use for PPT, PowerPoint, slide deck, presentation deck, 簡報, or 投影片 work that should follow a structured pipeline: confirm intake in PPT Design Studio, build a browser preview, apply component comments on request, then export a clean PPTX only after approval.
---

# Momo Pipeline

Momo Pipeline is a presentation production orchestration skill. It decides when to use design discussion, design-intelligence lookup, browser preview, HTML/React slide tooling, PPTX export tooling, and cleanup/QA helpers.

## Trigger

Use this skill when the user asks to create, redesign, improve, preview, export, or package a PPT, PowerPoint, slide deck, presentation deck, 簡報, or 投影片 and wants a repeatable design workflow.

Also use it when the user asks for:

- `/PPT`
- PPT Design Studio
- open-slide preview
- baoyu-design export
- company-template PPT output
- editable PPTX output
- browser-preview slide workflow
- slide-level or component-level visual adjustment before export

## Dependency Preflight

First resolve `MOMO_PLUGIN_ROOT` to the plugin root that contains this skill's
`skills/`, `scripts/`, and `assets/` directories. Do not assume the current
working directory is the plugin directory.

- In Claude Code, the plugin root is `${CLAUDE_SKILL_DIR}/../..` for this skill.
- In Codex, use the `SKILL.md` path from the available-skills catalog and walk up
  two directories.

Before production work, check the environment:

```bash
"$MOMO_PLUGIN_ROOT/scripts/check-env.sh"
```

If dependencies are missing and this plugin package is available locally, install them:

```bash
"$MOMO_PLUGIN_ROOT/scripts/install.sh"
```

Runtime dependencies live under `${MOMO_PIPELINE_HOME:-$HOME/.momo-pipeline}`
so the same installed plugin works in Codex and Claude Code without assuming a
host-specific cache path.

Companion design skills are optional but recommended:

- `ui-ux-pro-max`: design intelligence database for chart selection, UX rules, typography, color/style references, landing/deck structures, and stack guidance.
- `design-taste-frontend` / `taste-skill`: visual quality guardrail for anti-generic layout, hierarchy, spacing, and polish.

If companion skills are missing, continue with native PPT Design Studio reasoning. Do not block the deck workflow only because optional design skills are absent.

## Intent And Template Resolution

Resolve these before broad file searches or design work.

### Named capability training

When the user asks for a deck that teaches a named skill, plugin, app, or capability, the deck topic is that named capability's workflow. For example, `教同事怎麼使用 momo-pipeline` means the deck must teach the Momo Pipeline phases, prompts, approval gate, preview adjustment, export, and troubleshooting. Do not silently broaden it into a generic Codex or AI introduction.

### Template priority

Use this priority order:

1. An exact PPTX attached or explicitly named by the user.
2. A template path stated in the current task or project instructions.
3. The packaged Dingxin default at `assets/templates/PPT模板.pptx` when the user asks for a Dingxin template without naming another file.
4. A clearly identified project template.
5. Ask one concise question only when multiple unresolved candidates would materially change the result.

Once an exact template is available, stop searching for alternative templates. Treat it as a visual and structural constraint, not as optional inspiration.

Before authoring, verify the template is readable and inspect a bounded representative set:

- cover page;
- one section divider;
- one or two body layouts;
- closing page.

Do not exhaustively render or analyze every template slide unless layout selection requires it.

For the packaged Dingxin template, prefer the blue `鼎新數智` visual system. Preserve its cyan/blue palette, white space, lower-right brand lockup, rounded-line footer treatment, section-number pages, and blue closing page.

### Fast first pass

After the dependency check and bounded template inspection, show the Studio board and proposed slide architecture promptly. Do not delay the confirmation conversation by fully reading unrelated optional skills, searching all historical decks, or performing an exhaustive asset inventory.

### Intake confirmation gate

This is a hard gate before slide code, browser-preview construction, or PPTX generation.

Unless the user has already supplied each item or explicitly says `不用確認`, `直接產`, `跳過設計板`, or equivalent, present and confirm:

1. **Page count / duration**: propose a recommended count plus useful alternatives.
2. **Content outline**: show the proposed slide architecture with one message/job per page.
3. **Art direction**: offer two or three concrete visual directions compatible with the resolved template, including palette, typography, density, and image/diagram treatment.
4. **Text density and motion**: state the recommended density and whether the browser preview is static, subtle, or animated.

Wait for the user's response before writing `slides/<id>/index.tsx`, starting a preview build, or generating PPTX.

Authorization to `做一份PPT`, `產出示範PPT`, or similar authorizes the presentation task but does not by itself approve page count, outline, or art direction. Do not convert task authorization into silent design approval.

If an exact company template is supplied, the template resolves brand constraints but does not resolve page count, content outline, density, or motion. Confirm the unresolved choices.

The Studio response must include this compact decision surface:

```text
/PPT Design Studio
Topic:
Audience:
Deck job:
Recommended page count:
Proposed outline:
Art direction options:
Text density:
Motion:
Template:
Approval needed: yes
```

Do not begin Phase 2 until the user approves or explicitly skips this gate.

## Source Document Conversion

When source decks or documents are provided, do not call an arbitrary global `markitdown` command directly. Some desktop environments expose stale MarkItDown launchers. Use the plugin wrapper instead:

```bash
"$MOMO_PLUGIN_ROOT/scripts/convert-source-to-markdown.sh" <source-file> <output.md>
```

The wrapper uses the managed MarkItDown environment under
`${MOMO_PIPELINE_HOME:-$HOME/.momo-pipeline}/tools/markitdown-venv` first. It
falls back to built-in parsing for PPTX, DOCX, text, Markdown, HTML, and CSV
files if MarkItDown is unavailable or fails on the source.

If conversion is incomplete, state what could not be extracted and continue with direct source inspection or visual rendering.

## Required Workflow

### Phase 1 - PPT Design Studio

Do not immediately generate the final PPTX unless the user explicitly says to skip discussion or says "直接產".

#### 1A - Design Intelligence Pass

Before proposing the visual direction, use available design intelligence:

- For chart/data-heavy slides, query `ui-ux-pro-max` domains `chart`, `ux`, and `typography`.
- For pitch, sales, product, or landing-style decks, query `ui-ux-pro-max` design-system plus `landing`, `style`, `color`, and `typography`.
- For ERP/T100/internal-operation decks, do not blindly trust landing-page `--design-system` output. Prefer targeted `chart`, `ux`, `typography`, and dashboard/data-density guidance.
- For frontend/dashboard implementation decks, also query the relevant stack guidance.
- After UI/UX lookup, apply `design-taste-frontend` / `taste-skill` constraints to reduce AI-generic patterns and improve layout, hierarchy, spacing, visual rhythm, and polish.

Use the plugin helper so Codex and Claude Code skill locations are resolved
consistently:

```bash
"$MOMO_PLUGIN_ROOT/scripts/design-intelligence.sh" "<query>" --kind data
"$MOMO_PLUGIN_ROOT/scripts/design-intelligence.sh" "<query>" --kind pitch --project "<Project Name>"
```

Use the results as evidence-informed design guidance, not as an unquestioned template.

#### 1B - Studio Board

Open a concise design board:

```text
/PPT Design Studio
Brief read:
Audience:
Deck job:
Narrative spine:
Visual direction:
Slide count:
Source status:
UI/UX Pro Max findings:
Taste-skill constraints:
Approval needed:
```

Then provide a slide architecture table:

```text
Slide | Message | Layout | Visual/Data Need | Status
```

Rules:

- Each slide has one job.
- Titles should be message titles, not generic labels.
- Discuss style at slide level: cover, section, body, chart/table, screenshot/evidence, appendix, closing.
- If source files are provided, inspect before proposing the final deck.
- If a company template is provided, treat it as a visual constraint, not just a background.
- Keep UI/UX findings and taste constraints visible enough that the user can approve or reject the direction before preview work begins.

### Phase 2 - Interactive open-slide Preview

This phase is the user-facing review and adjustment loop. It is not PPTX export.

Use open-slide when possible.

Default workspace:

```text
work/<kebab-case-project-name>
```

Initialize:

```bash
"$MOMO_PLUGIN_ROOT/scripts/init-open-slide-project.sh" work/<kebab-case-project-name>
```

#### Phase 2A - Build And Serve Preview

Start an open-slide dev or preview server and expose the localhost URL.

Rules:

- Serve over localhost, not `file://`.
- Use a fixed 16:9 slide canvas.
- Put assets next to the slide project under a local asset folder.
- Run build checks before asking the user to review if the preview is not already stable.

#### Phase 2B - Open Preview In Browser

Open the preview page for the user in a real browser.

Preferred order:

1. Safari opening capability, if available.
2. Chrome opening capability, if available.
3. Script fallback:

```bash
"$MOMO_PLUGIN_ROOT/scripts/open-preview.sh" <preview-url>
```

If using Codex Browser, Chrome, or Playwright tools, use them for navigation, inspection, and screenshots. This does not replace opening the preview for the user when the user asked to adjust the deck visually.

After opening the browser, report:

- Preview URL
- Workspace path
- How the user can request component changes
- That PPTX export is waiting for approval

#### Phase 2C - Component Adjustment Loop

Wait for user-requested changes before exporting PPTX. The user may refer to elements by slide and component, for example:

- `第 3 頁標題改短`
- `第 4 頁右側藍色卡片放大`
- `第 5 頁表格第二欄改成深藍`
- `把第 6 頁流程箭頭往下移`

When editing open-slide code:

- Prefer adding clear `data-label` component names to major slide elements.
- Map user comments to specific slide components.
- Edit only the affected slide/component.
- Refresh and rebuild the browser preview.
- Reopen or refresh the preview page if needed.
- Show what changed and ask whether to continue adjusting or export.

##### Inspector comments and `/apply-comments`

Major editable elements should have stable, human-readable `data-label`
attributes so the user can select a specific component in the open-slide
inspector. When the user adds a preview comment, open-slide writes an
`@slide-comment` marker into the enclosing JSX element.

Adding a comment does **not** wake or automatically run the agent. Wait until
the user explicitly sends `/apply-comments`, asks to apply comments, or invokes
the bundled `apply-comments` skill. Then:

1. Read the pending `@slide-comment` markers in `slides/*/index.tsx`.
2. Decode and map each marker to its enclosing component and `data-label`.
3. Make only the requested slide/component changes.
4. Remove only the markers whose changes were successfully applied.
5. Rebuild and refresh the browser preview.
6. Report `N applied, M skipped` and wait for further review.

If a comment deletes a page or otherwise changes the approved page count,
preserve the approved total unless the comment explicitly changes it; add a
replacement page or ask a concise question when content intent is unclear.

`/apply-comments` is preview-edit approval only. It is not approval to export a
PPTX and does not bypass the Phase 3 gate.

Hard gate:

- Do not create the final PPTX during Phase 2.
- Do not automatically enter Phase 3 after preview QA.
- Only enter Phase 3 when the user explicitly says something like `輸出PPT`, `產PPTX`, `可以輸出`, `正式產`, or `進第三步`.

If the user explicitly requests direct generation, the gate may be skipped. A request to `產出示範PPT` alone does not waive preview approval when project rules require a preview first.

If open-slide is not available, use equivalent local HTML/React slide tooling, but preserve the same browser-opening and component-adjustment loop.

### Phase 3 - PPTX Export

Default goal: editable PPTX.

Use baoyu-design `gen-pptx` when exporting from an HTML/React deck:

```bash
"$MOMO_PLUGIN_ROOT/scripts/export-html-to-pptx.sh" <served-deck-url> <config-json> <out-dir>
```

Use native PPTX generation instead when:

- The user requires a strict `.pptx` company template.
- The deck must preserve theme/master/layout behavior.
- The source is already a PPTX and needs restructuring.
- HTML exporter cannot preserve enough editability.

If pixel-perfect output matters more than editability, screenshot-based PPTX/PDF export is acceptable, but state that editability is reduced.

Before baoyu-design export, do not pass untrusted ICNS, JXL, HEIF, or HEIC
assets to the current upstream image-size parser. Convert them to PNG or JPEG.
The export wrapper enforces this for local project assets it can discover.

### Phase 4 - Cleanup QA

Before final delivery:

1. Remove unused placeholders and template prompt text.
2. Remove duplicate titles and redundant text boxes.
3. Check overlapping text.
4. Check missing images.
5. Check screenshots are not distorted.
6. Check text does not run off-slide.
7. Render final PPTX to PDF/PNG for visual verification when possible.

Placeholder cleanup examples:

- `單擊此處編輯...`
- `点击此处编辑...`
- `Click title`
- `Click subtitle`

Use:

```bash
python "$MOMO_PLUGIN_ROOT/scripts/cleanup-pptx-placeholders.py" input.pptx output.pptx
```

If the script path is inside the installed plugin, use the absolute script path.

## Troubleshooting

### Invalid macOS temporary directory

Some Codex desktop sessions inherit a stale `TMPDIR` whose directory no longer exists. All plugin Node, pnpm, and export scripts must validate the inherited path and fall back to `/tmp` when it is missing or not writable. A temp-directory failure is an environment issue, not a slide-code failure; retry once with the safe fallback before changing deck code.

### Unsupported prompt cache parameter

If the host reports `prompt_cache_retention is not supported on this model`, treat it as a model-routing compatibility warning. Momo Pipeline does not require or set this parameter. Continue the local deck workflow without it when the host allows, report the boundary once, and do not repeatedly retry model calls with the same unsupported option.

### Status communication

During long template conversion, dependency installation, or preview startup, give a short status update within 60 seconds. State which artifact is being inspected or built and distinguish warnings from blocking failures.

## Output Rules

Deliver user-facing files under the current thread project `outputs/` folder.

Final response should include:

- PPTX path
- Optional PDF preview path
- Source files used
- Whether visual verification succeeded
- Assumptions and limitations, especially if editability was reduced

## Tool Fallback Rules

Use exact named tools when available, but do not fail only because a preferred tool is absent.

- PPT Design Studio absent: emulate the board and slide architecture table directly.
- `ui-ux-pro-max` absent: continue with native design reasoning and state that database lookup was skipped.
- `design-taste-frontend` / `taste-skill` absent: continue with native visual quality review and state that external taste skill was skipped.
- open-slide absent: create local HTML/React preview with fixed 16:9 slides and browser verification.
- baoyu-design absent: install it with
  `"$MOMO_PLUGIN_ROOT/scripts/install.sh"`, or use native PPTX export when more
  appropriate.
- LibreOffice absent: use any available PPTX-to-PDF/PNG renderer; if none is available, inspect the PPTX object tree and state the visual verification gap.

## Strong Defaults

- Prefer editable PPTX.
- Prefer preview before final export.
- Prefer company template fidelity over decorative novelty.
- Keep final slides clean of inherited template prompts.
- Do not leave users to manually delete extra title boxes or placeholders.
- When in doubt, preserve evidence and state unverified gaps plainly.
