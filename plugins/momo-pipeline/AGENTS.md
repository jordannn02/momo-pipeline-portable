# momo-pipeline Agent Instructions

If you are an AI agent reading this plugin package, start with:

1. `README.md`
2. `skills/momo-pipeline/SKILL.md`
3. `scripts/check-env.sh`

## Core Contract

Momo Pipeline is the top-level presentation production workflow.

Do not treat it as only a PPTX exporter. It orchestrates:

1. PPT Design Studio discussion.
2. Optional UI/UX Pro Max design-intelligence lookup.
3. Optional taste-skill visual quality pass.
4. Browser/open-slide preview and component-level adjustment.
5. Explicit `/apply-comments` processing for inspector markers.
6. PPTX export after explicit approval.
7. Cleanup and visual QA.

Resolve the user's exact topic and template before broad discovery. A named capability training deck teaches that capability, not generic Codex usage. An attached or explicitly named PPTX is authoritative. If the user requests a Dingxin template without naming another file, use `assets/templates/PPT模板.pptx`.

Task authorization is not silent design approval. Unless the user already supplied the decisions or explicitly requested direct generation, stop at a hard intake gate and confirm page count, slide outline, art direction, text density, and motion before writing slide code or starting a preview build.

## Dependency Setup

Before production work, run:

```bash
"$MOMO_PLUGIN_ROOT/scripts/check-env.sh"
```

If required dependencies are missing and this plugin folder is available locally:

```bash
"$MOMO_PLUGIN_ROOT/scripts/install.sh"
```

Resolve `MOMO_PLUGIN_ROOT` from this plugin's installed path; never assume the
current working directory is the plugin root. Runtime dependencies live under
`${MOMO_PIPELINE_HOME:-$HOME/.momo-pipeline}`. The scripts validate `TMPDIR`
and fall back to `/tmp` when the inherited macOS temporary directory is stale
or unwritable.

## Design Intelligence

Use optional companion skills when available:

- `ui-ux-pro-max`: query chart, UX, typography, color/style, landing/deck structure, and stack guidance.
- `design-taste-frontend` / `taste-skill`: apply anti-generic layout, hierarchy, spacing, and visual polish constraints.

Use helper:

```bash
"$MOMO_PLUGIN_ROOT/scripts/design-intelligence.sh" "<deck brief>" --kind data
"$MOMO_PLUGIN_ROOT/scripts/design-intelligence.sh" "<deck brief>" --kind pitch
"$MOMO_PLUGIN_ROOT/scripts/design-intelligence.sh" "<deck brief>" --kind erp
```

If companion skills are missing, continue with native design reasoning and state that the optional lookup was skipped.

## Source Conversion

For source documents or decks, do not call arbitrary global `markitdown`. Use the managed wrapper:

```bash
"$MOMO_PLUGIN_ROOT/scripts/convert-source-to-markdown.sh" <source-file> <output.md>
```

The installer creates an optional MarkItDown environment under
`${MOMO_PIPELINE_HOME:-$HOME/.momo-pipeline}/tools/markitdown-venv`. It does not
replace a global `markitdown` launcher.

## Workflow Phases

1. **PPT Design Studio**
   - Lock the requested topic and exact template first.
   - Inspect source material and a bounded set of representative template pages.
   - Propose page count, one-job-per-page outline, 2-3 concrete art directions, text density, and motion.
   - Wait for approval before slide code or preview construction unless the user explicitly skips confirmation.
   - Run design-intelligence lookup when available.
   - Show Studio board with UI/UX findings and taste constraints.
   - Create slide architecture table.

2. **Interactive Browser Preview**
   - Build open-slide or equivalent HTML/React slides.
   - Serve over localhost.
   - Open preview in Safari, Chrome, or system browser.
   - Wait for component-level change requests.
   - Give major editable elements stable, human-readable `data-label` values.
   - Adding a preview comment does not wake the agent. Apply pending
     `@slide-comment` markers only after the user sends `/apply-comments` or
     explicitly asks to apply comments.
   - Rebuild and refresh after applying comments; this is not export approval.

3. **PPTX Export**
   - Export only after user approval unless direct generation was requested.
   - Prefer editable PPTX.
   - Use baoyu-design for HTML/React deck export.
   - Use native PPTX generation for strict company-template fidelity.

4. **Cleanup QA**
   - Remove leftover placeholders like `單擊此處編輯...`.
   - Check overlap, wrapping, missing images, distorted screenshots, duplicate titles, and off-slide objects.
   - Render or visually inspect final output when possible.

## Delivery

Put user-facing files under the current thread/project `outputs/` folder.

Final response should state:

- PPTX path
- Preview path if created
- Source files used
- Whether visual verification succeeded
- Any limitations, especially reduced editability

## Routing Warning Boundary

`prompt_cache_retention is not supported on this model` is a host/model-routing compatibility warning. This plugin does not set or require that parameter. Continue without it when possible and do not misreport it as a PPT generation failure.
