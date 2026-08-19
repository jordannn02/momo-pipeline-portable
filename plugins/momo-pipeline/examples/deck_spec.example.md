# Deck Spec Example

This file is a suggested source of truth between PPT Design Studio, design-intelligence lookup, browser preview, and PPTX export.

## Deck

- Title: 報價單取價條件與接單議題整理
- Audience: 客戶窗口、顧問、PM
- Language: zh-TW
- Output: editable PPTX
- Template: company-template.pptx
- Preview workflow: open-slide localhost preview
- Export workflow: baoyu-design if HTML deck is used; native PPTX if strict company-template fidelity is required

## Source Status

- Source deck: `source/company-template.pptx`
- Source notes: `source/meeting-notes.md`
- Source screenshots: `source/screenshots/`
- Conversion: use `scripts/convert-source-to-markdown.sh`
- Evidence gaps: list any missing data, unavailable screenshots, or unverified claims here

## PPT Design Studio

```text
/PPT Design Studio
Brief read: T100 quotation pricing and order-entry confirmation deck
Audience: 客戶窗口、顧問、PM
Deck job: Align decisions and unresolved rules
Narrative spine: From current quotation logic to rules requiring confirmation
Visual direction: Corporate blue, clean evidence-led consulting style
Slide count: 7
Source status: Template + notes + screenshots available
UI/UX Pro Max findings: Use decision tables, workflow diagrams, restrained CJK typography, high-contrast chart/table labels
Taste-skill constraints: Avoid generic three-card repetition, oversized empty hero text, decorative gradients, and fake UI
Approval needed: yes, before browser preview build
```

## Design Intelligence Notes

Recommended helper:

```bash
./scripts/design-intelligence.sh "T100 quotation pricing order-entry confirmation ERP decision deck" --kind erp --project "T100 Quotation Deck"
```

Summarize the useful output here:

- Chart/data guidance:
- UX/accessibility guidance:
- Typography guidance:
- Color/style guidance:
- Anti-patterns to avoid:

## Slide Architecture

| Slide | Message | Layout | Visual/Data Need | Status |
|---|---|---|---|---|
| 1 | 報價單取價條件與接單議題整理 | Cover | Title, date, project | planned |
| 2 | 本次需要確認的四類接單議題 | Executive summary | 4 issue cards or decision strip | planned |
| 3 | 報價單身由彈性條件展開 | Workflow | Screenshot + process nodes | planned |
| 4 | 售價由公式產生，但保留手動調整空間 | Formula | Formula + editable fields | planned |
| 5 | 取價條件的應用與來源 | Table | Condition mapping table | planned |
| 6 | 接單取價的待確認規則 | Decision table | Issue/current/to confirm | planned |
| 7 | 畫面證據與欄位截圖 | Appendix | Source screenshots | planned |

## Visual System

- Palette: cyan, blue, navy, white, light gray
- Typography: CJK sans-serif, strong message titles, compact table labels
- Screenshots: framed, undistorted, labeled
- Tables: dark header, alternating pale rows, clear status chips
- Diagrams: simple nodes and directional connectors, no decorative clutter
- QA: no template placeholders, no duplicate titles, no off-slide text

## Preview Notes

- Workspace: `work/t100-quotation-deck`
- Preview URL:
- Component labels:
  - `slide-3.workflow-main`
  - `slide-4.formula-panel`
  - `slide-6.decision-table`
- Pending user edits:

## Export Notes

- Use browser preview for design review.
- Use editable PPTX export unless user explicitly requests pixel-perfect screenshots.
- If strict company-template fidelity is required, use native PPTX generation and run placeholder cleanup.
- Final output path: `outputs/<deck-name>.pptx`
- Optional preview PDF/PNG path:
