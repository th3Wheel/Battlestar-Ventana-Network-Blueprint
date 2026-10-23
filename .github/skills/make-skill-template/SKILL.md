---
name: make-skill-template
description: 'Create new Agent Skills for GitHub Copilot from prompts or by duplicating this template. Use when asked to "create a skill", "make a new skill", "scaffold a skill", or when building specialized AI capabilities with bundled resources. Generates SKILL.md files with proper frontmatter, directory structure, and optional scripts/references/assets folders.'
---

# Make Skill Template

A meta-skill for creating new Agent Skills. Use this skill when you need to scaffold a new skill folder, generate a SKILL.md file, or help users understand the Agent Skills specification.

## When to Uset This Skill

- User asks to "create a skill", "make a new skill", or "scaffold a skill"
- User wants to add a specialized capability to their GitHub Copilot setup
- User needs help strucuring a skill with bundled resources
- User wants to duplicate this template as a starting point

## Prerequisites

- Understanding of what the skill should accomplish. If its purpose, intended users, or expected behavior is unclear, ask targeted questions and wait for answers before drafting the skill.
- A clear, keyword-rich description of capabilities and triggers
- Knowledge of any bundled resources needed (scripts, references, assets, templates)

## Creating a New Skill

### Step 1: Create the Skill Directory

For project skills in this repository, create the skill under
`.agents/skills/<skill-name>/` first. Before creating it, search for an
existing skill in this order: `.agents/skills/`, `.github/skills/`,
`.claude/skills/`, `.codex/skills/`, then other host-specific locations.
These are authoring and search conventions; the Agent Skills specification
does not define host discovery or precedence, and support varies by host.

If the requested name contains uppercase letters, spaces, or invalid
characters, suggest a valid lowercase name and ask the user to confirm it
before creating the folder. Ask the user how to proceed if a skill with that
name already exists; do not overwrite or merge without approval.

Create the skill directory with a `SKILL.md` file:

```
.agents/skills/<skill-name>/
└── SKILL.md          # Required
```

The skill directory may also contain any additional files and directories
needed by the skill.

### Step 2: Generate SKILL.md with Frontmatter

Every `SKILL.md` requires YAML frontmatter followed by Markdown instructions.
The required `name` and `description` fields are:

```yaml
---
name: <skill-name>
description: <What it does and when to use it, including relevant keywords.>
---
```

#### Frontmatter Field Requirements

| Field | Required | Constraints |
|-------|----------|-------------|
| `name` | Yes | 1-64 characters; lowercase letters (`a-z`), digits (`0-9`), and hyphens only; no leading, trailing, or consecutive hyphens; must match the parent directory name |
| `description` | Yes | 1-1024 characters; non-empty; describes what the skill does and when to use it |
| `license` | No | License name or reference to a bundled license file |
| `compatibility` | No | 1-500 characters; include only for specific environment requirements |
| `metadata` | No | A mapping of string keys to string values for additional metadata |
| `allowed-tools` | No | Space-separated pre-approved tools; experimental, with support varying by agent |

#### Description Guidance

Describe both the skill's purpose and the situations in which an agent should
use it. Include specific task keywords that help agents identify relevant
requests. Keep descriptions concise and within the 1-1024 character limit.

Good example:

```yaml
description: Extracts text and tables from PDF files, fills PDF forms, and merges multiple PDFs. Use when working with PDF documents, forms, or document extraction.
```

Weak example:

```yaml
description: Helps with PDFs.
```

The specification does not require descriptions to be quoted in YAML; quote
them when needed for valid YAML parsing, such as when the text contains syntax
that YAML could interpret specially.

#### Optional Metadata

Add optional fields only when useful. `compatibility` is for concrete
environment requirements. `metadata` must be a mapping whose values are
strings; use distinctive keys to avoid collisions. `allowed-tools` is
experimental and may not be honored by every agent. Do not treat tool
allowlisting as a substitute for runtime permissions or approval controls.

Example using optional fields:

```yaml
license: Apache-2.0
compatibility: Requires Python 3.14+ and uv
metadata:
  author: example-org
  version: "1.0"
allowed-tools: Bash(git:*) Bash(jq:*) Read
```

Fields such as `id`, `applyTo`, and `disable-model-invocation` are not core
Agent Skills specification fields. Use them only when a target host documents
and supports them; do not present them as portable Agent Skills metadata.

### Step 3: Write the Skill Body

After the frontmatter, write Markdown instructions appropriate to the skill.
There are no required body sections. Useful content may include step-by-step
instructions, examples, and common edge cases. The agent loads the full
`SKILL.md` when the skill is activated, so keep instructions focused.

### Step 4: Add Optional Directories (If Needed)

| Folder | Purpose | When to Use |
|--------|---------|-------------|
| `scripts/` | Executable code | Include self-contained scripts or document their dependencies; provide helpful errors and handle edge cases |
| `references/` | Additional documentation | Keep reference files focused and load them only when needed |
| `assets/` | Static resources | Include templates, images, or data files used by the skill |

These are common organizational conventions, not the only allowed directories.
Any additional files and directories may be included when useful.

## Example: Skill Directory Structure

```
skill-name/
├── SKILL.md          # Required: metadata + instructions
├── scripts/          # Optional: executable code
├── references/       # Optional: documentation
├── assets/           # Optional: static resources
└── ...               # Any additional files or directories
```

## Progressive Disclosure

Structure the skill so agents can load details as needed:

1. **Metadata:** `name` and `description` are used to identify relevant skills.
2. **Instructions:** The full `SKILL.md` body is loaded when the skill is activated.
3. **Resources:** Supporting files are loaded or used only when needed.

Keep `SKILL.md` under 500 lines and the instructions under 5,000 tokens
where practical. Move detailed material into focused resource files.

## File References

Reference bundled files using paths relative to the skill directory:

```markdown
See [the reference guide](references/REFERENCE.md).

Run the helper:
scripts/extract.py
```

Keep references one level deep from `SKILL.md` so agents can locate resources
without following long chains of links.

## Quick Start: Duplicate This Template

1. Use this template as the starting point for the new skill.
2. Create `.agents/skills/<skill-name>/` for a project skill in this repository.
3. Update `SKILL.md`:
   - Change `name:` to match folder name
   - Write a concise `description:` describing purpose and when to use it
   - Replace body content with your instructions
4. Add bundled resources as needed
5. Validate with the reference validator, if it is installed:

   ```sh
   skills-ref validate .agents/skills/<skill-name>
   ```

   If it is unavailable, report that and use the checklist below. Do not
   imply that a manual review is equivalent to running the validator.

## Validation Checklist

- [ ] `SKILL.md` begins with valid YAML frontmatter followed by Markdown
- [ ] `name` is 1-64 characters, uses lowercase letters, digits, or single hyphens, and matches the parent directory name
- [ ] `description` is non-empty, 1-1024 characters, and explains what the skill does and when to use it
- [ ] Optional fields follow their specification constraints; `metadata` values are strings
- [ ] `SKILL.md` is under 500 lines; instructions are under 5,000 tokens where practical
- [ ] Bundled file references are relative to the skill root and one level deep

## Troubleshooting

| Issue | Solution |
|-------|----------|
| Skill is not discovered | Check that the host supports the skill location and format; review the description for clear purpose and relevant use cases |
| Validation fails on name | Use lowercase letters, digits, and single hyphens; ensure the name matches the parent directory |
| Validation fails on metadata | Check field spelling, value types, and documented limits |
| A bundled file is not found | Use a path relative to the skill root and verify the file exists |

## References

- [Agent Skills specification](https://agentskills.io/specification)
- [Agent Skills documentation index](https://agentskills.io/llms.txt)
- [Reference validator (`skills-ref`)](https://github.com/agentskills/agentskills/tree/main/skills-ref)
