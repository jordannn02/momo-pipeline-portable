# Privacy

`momo-pipeline` runs local scripts and local preview/export tooling. It does not send user presentation content to a remote service by itself.

## Local Operations

The plugin may:

- Convert source files to Markdown using a managed local MarkItDown environment.
- Create local open-slide or HTML/React preview workspaces.
- Open a localhost browser preview.
- Export PPTX through local baoyu-design tooling or native PPTX generation.
- Inspect or modify local PPTX files for cleanup/QA.
- Query local `ui-ux-pro-max` CSV/script databases if that optional skill is installed.

## Network Operations

During installation, the plugin may clone or update public repositories:

- `https://github.com/1weiho/open-slide`
- `https://github.com/jimliu/baoyu-design`

Optional companion skill installation may also access public npm/GitHub resources:

- `ui-ux-pro-max-cli`
- `Leonxlnx/taste-skill`

The plugin does not intentionally upload presentation content. However, the surrounding AI runtime, browser tooling, connectors, or user-selected external tools may have their own network behavior.

## Confidential Materials

Before using confidential company templates, screenshots, financial data, ERP exports, or customer material:

- Keep source files local.
- Prefer the managed local conversion wrapper.
- Review browser preview and export tooling policies.
- Avoid pasting secrets, passwords, API keys, or private customer data into prompts unless necessary and approved.

## User Responsibility

Review your AI runtime, installed plugins, browser tools, and export pipeline before using sensitive files. If a workflow would require external services, state that clearly before proceeding.
