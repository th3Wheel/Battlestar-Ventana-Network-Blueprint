---
description: 'Guidelines for creating high-quality Agent Skills for GitHub Copilot'
applyTo: '**/skills/**/SKILL.md'
---

# Agent Skills File Guidelines

Instructions for creating effective and portable Agent Skills that enhance GitHub Copilot with specialized capabilities, workflows, and bundled resources.

## Scope and Source of Truth

Follow the [Agent Skills specification](https://agentskills.io/specification)
for portable format requirements. Host documentation governs discovery and
invocation behavior. Sections labeled as repository conventions or authoring
advice are not additional requirements of the portable format.

This instruction file's `description` and `applyTo` configure the guideline
itself. They do not define the frontmatter schema for a `SKILL.md` file.

## Contents

- [What Are Agent Skills?](#what-are-agent-skills)
- [Directory Structure](#directory-structure)
- [Required SKILL.md Format](#required-skillmd-format)
- [Bundling Resources](#bundling-resources)
- [Progressive Loading Architecture](#progressive-loading-architecture)
- [Content Guidelines](#content-guidelines)
- [Writing High-Impact Skills](#writing-high-impact-skills)
- [Common Patterns](#common-patterns)
- [Validation Checklist](#validation-checklist)
- [Related Resources](agent-skills.instructions.md#related-resources)

## What Are Agent Skills?

Agent Skills are self-contained folders with instructions and bundled resources that teach AI agents specialized capabilities. Unlike custom instructions (which define coding standards), skills enable task-specific workflows that can include scripts, examples, templates, and reference data.

Key characteristics:

- **Portable**: A shared format for supporting agents; host capabilities vary
- **Progressive loading**: Metadata is loaded before detailed instructions
- **Resource-bundled**: Can include scripts, templates, examples alongside instructions
- **On-demand**: Hosts may activate skills based on relevance or explicit invocation

## Directory Structure

The specification requires a skill directory containing `SKILL.md`; it does
not prescribe host search paths. The following are repository authoring and
search conventions, not guarantees of automatic discovery:

| Location                          | Scope                | Recommendation                                       |
| --------------------------------- | -------------------- | ---------------------------------------------------- |
| `.agents/skills/<skill-name>/`    | Project/repository   | Recommended for project skills                       |
| `.github/skills/<skill-name>/`    | Project/repository   | Alternative for project skills                       |
| `.claude/skills/<skill-name>/`    | Project/repository   | Check when searching existing skills                 |
| `.codex/skills/<skill-name>/`     | Project/repository   | Check for Codex-specific skills; host support varies |
| `~/.copilot/skills/<skill-name>/` | Personal (user-wide) | Recommended for personal skills                      |
| `~/.agents/skills/<skill-name>/`  | Personal (user-wide) | Alternative candidate; confirm host support          |
| `~/.claude/skills/<skill-name>/`  | Personal (user-wide) | Check when searching existing personal skills        |

For project skills, create and maintain skills in `.agents/skills/` first. When
searching a repository for existing skills, check `.agents/skills/`,
`.github/skills/`, `.claude/skills/`, and `.codex/skills/` in that order, then
check other applicable host-specific locations. This is the repository's
authoring and search convention; automatic discovery and precedence depend on
the host, and not every host supports every location.

Each skill **must** have its own subdirectory containing at minimum a `SKILL.md` file.

## Required SKILL.md Format

### Frontmatter (Required)

Use YAML frontmatter followed by Markdown instructions. Minimal example for
a directory named `webapp-testing`:

```yaml
---
name: webapp-testing
description: Test local web applications. Use for browser-based verification.
---
```

| Field           | Required | Constraints                                                                                                                                           |
| --------------- | -------- | ----------------------------------------------------------------------------------------------------------------------------------------------------- |
| `name`          | Yes      | String, 1-64 characters; lowercase alphanumeric characters and hyphens; must match the parent directory; no leading, trailing, or consecutive hyphens |
| `description`   | Yes      | Non-empty string, 1-1024 characters; describe capabilities and when to use the skill                                                                  |
| `license`       | No       | License name or reference to a bundled license file                                                                                                   |
| `compatibility` | No       | String, 1-500 characters when provided; specific environment requirements                                                                             |
| `metadata`      | No       | Mapping of string keys to string values                                                                                                               |
| `allowed-tools` | No       | Space-separated string of pre-approved tools; experimental and host-dependent                                                                         |

Use valid YAML strings. Single quotes, double quotes, and plain scalars are
acceptable; quote values when YAML syntax or implicit typing requires it.
Do not impose a ten-character minimum on descriptions.

### Names and Optional Fields

The reference validator supports Unicode alphanumeric names, applying NFKC
normalization and a lowercase check. As a **repository convention**, prefer
ASCII lowercase letters, digits, and single hyphens for portability. Examples:
`webapp-testing` and `pdf2-text` are valid; `Webapp`, `-webapp`, `webapp-`,
and `webapp--testing` are invalid. Always match the parent directory name.

Include `compatibility` only for specific requirements such as installed tools,
network access, or an intended host. Most skills do not need it.

Use reasonably unique keys in `metadata` for custom properties, including
identifiers. Quote numeric-looking versions and boolean-looking values so
they remain strings.

Example using all optional fields for a directory named `webapp-testing`:

```yaml
---
name: webapp-testing
description: Test local web applications. Use for browser-based verification.
license: Apache-2.0
compatibility: Requires Node.js, Playwright, and a locally running web application.
metadata:
  example-org.skill-id: webapp-testing
  example-org.version: '1.0'
allowed-tools: Bash(npm:*) Read
---
```

The license is illustrative, not a default license assignment. The tool names
and argument syntax illustrate one host's convention; verify support before
using them. `allowed-tools` does not establish a portable security boundary.

### Nonstandard and Host-Specific Fields

`id`, `applyTo`, and `disable-model-invocation` are not fields in the portable
specification. Do not add them to portable frontmatter. Store a custom
identifier under `metadata` instead of recommending a top-level `id`.
If a skill needs host extensions, document them separately using that host's
official documentation and check its handling of nonstandard fields.

### Description Best Practices

The `name` and `description` form the lightweight discovery surface. Describe
capabilities and specific use cases clearly. A vague description makes relevant
selection less likely; activation and explicit invocation depend on the host.

**What to include in description:**

1. **WHAT** the skill does (capabilities)
2. **WHEN** to use it (specific triggers, scenarios, file types, or user requests)
3. **Keywords** that users might mention in their prompts

**Good description:**

```yaml
description: 'Toolkit for testing local web applications using Playwright. Use when asked to verify frontend functionality, debug UI behavior, capture browser screenshots, check for visual regressions, or view browser console logs. Supports Chrome, Firefox, and WebKit browsers.'
```

**Poor description:**

```yaml
description: 'Web testing helpers'
```

The poor description fails because:

- No specific triggers (when should Copilot load this?)
- No keywords (what user prompts would match?)
- No capabilities (what can it actually do?)

### Body Content

The body contains instructions loaded after activation. The specification
imposes no body format restrictions. The sections below and the content advice
later in this guideline are repository authoring recommendations, not schema
requirements. Include input/output examples and relevant edge cases.

| Section                     | Purpose                                                                |
| --------------------------- | ---------------------------------------------------------------------- |
| `# Title`                   | Brief overview of what this skill enables                              |
| `## When to Use This Skill` | List of scenarios (reinforces description triggers)                    |
| `## Prerequisites`          | Required tools, dependencies, environment setup (if applicable)        |
| `## Step-by-Step Workflows` | Numbered steps for repeatable procedures (build, deploy, setup)        |
| `## Gotchas`                | Proactive warnings about non-obvious behavior ("never do X because Y") |
| `## Troubleshooting`        | Reactive fixes for known issues ("if you see X, try Y")                |
| `## References`             | Links to bundled docs or external resources                            |

Not every skill needs every section. Skip `## Prerequisites` if there are no external dependencies. Skip `## Step-by-Step Workflows` if the skill is purely advisory. Include `## Gotchas` whenever the skill involves external tools, APIs, or platform-specific behavior.

For content quality principles (what to include and what to leave out), see [Writing High-Impact Skills](#writing-high-impact-skills) below.

### Writing Each Section

**`# Title`** — One sentence stating what the skill enables. Avoid generic phrasing; be specific about the domain.

**`## When to Use This Skill`** — A bullet list of concrete scenarios that reinforce the description triggers. This helps Copilot confirm it loaded the right skill.

```markdown
## When to Use This Skill

- User asks to test a web application in a browser
- User needs to capture screenshots for visual regression testing
- User wants to debug frontend behavior with browser console logs
```

**`## Prerequisites`** — Only include if the skill requires tools, services, or configuration that Copilot cannot assume are available. List exact install commands.

```markdown
## Prerequisites

- [Playwright](https://playwright.dev/) installed: `npm install -D @playwright/test`
- At least one browser engine installed: `npx playwright install chromium`
```

**`## Step-by-Step Workflows`** — Numbered steps for repeatable procedures where sequence matters (build, deploy, environment setup). Describe WHAT to accomplish at each stage, not hardcoded file paths or line numbers — steps should be adaptable to different project structures. Consider moving lengthy workflows into linked `references/` files; there is no five-step limit in the specification.

```markdown
## Step-by-Step Workflows

### Deploy to Staging

1. Build the project: `npm run build`
2. Run pre-deploy validation: `npm run validate`
3. Deploy to staging: `npm run deploy -- --env staging`
4. Verify the health endpoint returns 200
```

**`## Gotchas`** — Proactive warnings that prevent mistakes. Document non-obvious defaults, API quirks, version-specific behavior, and common traps. Bold the key constraint, then explain why.

```markdown
## Gotchas

- **Never** call `billing.charge()` without checking `user.hasPaymentMethod` first —
  the SDK throws an unrecoverable error instead of returning a failure.
- The `currency` field expects ISO 4217 codes, not display names.
  Copilot often writes "dollars" instead of "USD".
```

**`## Troubleshooting`** — Reactive fixes for known issues, presented as a table of symptom → solution pairs. Each row should be self-contained and actionable.

```markdown
## Troubleshooting

| Issue                    | Solution                                               |
| ------------------------ | ------------------------------------------------------ |
| Plugin won't connect     | Check servers are running (`npm run start:all`)        |
| Browser blocks localhost | Allow local network access, or try a different browser |
| Tool execution times out | Ensure the plugin UI is open and shows "Connected"     |
```

**`## References`** — Links to bundled docs in `references/`, external documentation, or related skills. Use relative paths for bundled files.

## Bundling Resources

A skill may contain any additional files and directories. `scripts/`,
`references/`, and `assets/` are optional standard conventions; `templates/`
is an optional repository convention. Resource access depends on the host and
task, not an unconditional rule about whether a directory enters context.

### Supported Resource Types

| Folder        | Purpose                                                 | Loaded into Context?                | Example Files                                        |
| ------------- | ------------------------------------------------------- | ----------------------------------- | ---------------------------------------------------- |
| `scripts/`    | Executable automation that performs specific operations | Source or output as needed          | `helper.py`, `validate.sh`, `build.ts`               |
| `references/` | Documentation the AI agent reads to inform decisions    | Yes, when referenced                | `api_reference.md`, `schema.md`, `workflow_guide.md` |
| `assets/`     | Static resources, including templates, images, and data | As needed and supported by the host | `logo.png`, `report-template.html`, `lookup.json`    |
| `templates/`  | Optional local organization for starter code/scaffolds  | As needed                           | `viewer.html`, `hello-world/`                        |

### Directory Structure Example

```text
.agents/skills/my-skill/
├── SKILL.md              # Required: Main instructions
├── LICENSE.txt           # Optional: Owner-selected license terms
├── scripts/              # Optional: Executable automation
│   ├── helper.py         # Python script
│   └── helper.ps1        # PowerShell script
├── references/           # Optional: Documentation loaded into context
│   ├── api_reference.md
│   ├── workflow-setup.md     # Detailed workflow
│   └── workflow-deployment.md
├── assets/               # Optional: Templates, images, data
│   ├── baseline.png      # Reference image for comparison
│   └── report-template.html
└── templates/            # Optional: Starter code the AI agent modifies
    ├── scaffold.py       # Code scaffold the AI agent customizes
    └── config.template   # Config template the AI agent fills in
```

Licensing is optional in this format. Use the owner's chosen license name or
reference a bundled license file when needed. Do not download or assign Apache
2.0 automatically, or change existing license terms without authorization.

### Assets and Templates

Templates may live in `assets/`, as the specification describes. This
repository may use `templates/` for editable scaffolds, but that is not a
required distinction. Neither directory makes a resource immutable. Explain
whether a resource should be read, copied, or adapted for the task.

### Referencing Resources in SKILL.md

Use paths relative to the skill root. Link resources directly from `SKILL.md`
and keep reference discovery one level deep; avoid chains of references that
require loading several documents to find the needed file.

```markdown
## Available Scripts

Run the [helper script](./scripts/helper.py) to automate common tasks.

See [API reference](./references/api_reference.md) for detailed documentation.

Use the [scaffold](./templates/scaffold.py) as a starting point.
```

## Progressive Loading Architecture

Skills use three-level loading for efficiency:

| Level           | What Loads                                                    | When                                            |
| --------------- | ------------------------------------------------------------- | ----------------------------------------------- |
| 1. Discovery    | `name` and `description` (approximately 100 tokens per skill) | At startup in the specification's loading model |
| 2. Instructions | Full `SKILL.md` body (under 5,000 tokens recommended)         | When the skill is activated                     |
| 3. Resources    | Scripts, references, assets, and other files                  | As needed for the task                          |

Metadata still consumes context even when a skill is not activated. Progressive
disclosure reduces initial loading; it does not make installed skills free.
Actual discovery, invocation, and resource access depend on the host.

## Content Guidelines

### Writing Style

- Use imperative mood: "Run", "Create", "Configure" (not "You should run")
- Be specific and actionable
- Include exact commands with parameters
- Show expected outputs where helpful
- Keep sections focused and scannable

### Script Requirements

When including scripts, prefer cross-platform languages:

| Language   | Use Case                            |
| ---------- | ----------------------------------- |
| Python     | Complex automation, data processing |
| pwsh       | PowerShell Core scripting           |
| Node.js    | JavaScript-based tooling            |
| Bash/Shell | Simple automation tasks             |

Best practices:

- Include help/usage documentation (`--help` flag)
- Handle errors gracefully with clear messages
- Avoid storing credentials or secrets
- Use relative paths where possible

### When to Bundle Scripts

Include scripts in your skill when:

- The same code would be rewritten repeatedly by the agent
- Deterministic reliability is critical (e.g., file manipulation, API calls)
- Complex logic benefits from being pre-tested rather than generated each time
- The operation has a self-contained purpose that can evolve independently
- Testability matters — scripts can be unit tested and validated
- Predictable behavior is preferred over dynamic generation

Scripts enable evolution: even simple operations benefit from being implemented as scripts when they may grow in complexity, need consistent behavior across invocations, or require future extensibility.

### Security Considerations

- Scripts rely on existing credential helpers (no credential storage)
- Include `--force` flags only for destructive operations
- Warn users before irreversible actions
- Document any network operations or external calls

## Writing High-Impact Skills

### Focus on What Copilot Doesn't Know

Do not include information Copilot already knows from its training data — standard language syntax, common library usage, or well-documented API behavior. Every line in a skill should teach something Copilot would otherwise get wrong or miss entirely. If the information is on the first page of official docs, leave it out. Focus on internal conventions, non-obvious defaults, version-specific quirks, and domain-specific workflows that change Copilot's behavior.

### Context Budget Awareness

All skill descriptions share a limited portion of the available context window during discovery. Your description competes with every other installed skill for Copilot's attention. Keep descriptions concise and keyword-dense — aim for the shortest text that still communicates WHAT, WHEN, and relevant KEYWORDS. Verbose descriptions don't just waste your own budget; they reduce visibility for every other skill in the system.

### Gotchas Are Your Highest-Signal Content

The `## Gotchas` section is consistently the most valuable part of any skill — proactive warnings that prevent mistakes before they happen. This is distinct from `## Troubleshooting`, which provides reactive fixes after something goes wrong. Treat gotchas as a living section: every time Copilot produces a wrong result, add a gotcha. Bold the key constraint, then explain why (e.g., "**Never** call `X()` without checking `Y` first — the SDK throws an unrecoverable error").

### Prefer Flexible Guidelines Over Rigid Steps

Use numbered steps only for concrete, repeatable procedures (build, deploy, environment setup) where the sequence genuinely matters. For open-ended tasks (debugging, refactoring, code review), provide decision criteria and reference information instead — Copilot needs flexibility to adapt to the user's specific situation.

```markdown
# ❌ Too rigid

1. Open the file at src/api/handlers.ts
2. Find the function named processOrder
3. Add a try-catch block around lines 45-60

# ✅ Flexible

When fixing error handling in API handlers:

- Ensure all database operations have proper error handling
- Use the project's ErrorHandler utility (see ./references/error-handling.md)
- Log errors with enough context to debug in production
```

### Use Progressive Disclosure for Large Skills

The specification recommends keeping the main `SKILL.md` under 500 lines and
the instructions under 5,000 tokens. These are authoring targets, not a
frontmatter validity limit. As a local heuristic, consider splitting detailed
content at approximately 200 lines. Move detail into directly linked reference
files and state when to load each file.

```markdown
## Reference Files

- `references/api.md` — complete function signatures and return types
- `references/error-codes.md` — every error code this service can return
- `scripts/validate.sh` — run this after making changes to verify correctness

Read these files as needed for your current task. Do not read them all upfront.
```

## Common Patterns

### Parameter Table Pattern

Document parameters clearly:

```markdown
| Parameter   | Required | Default | Description                  |
| ----------- | -------- | ------- | ---------------------------- |
| `--input`   | Yes      | -       | Input file or URL to process |
| `--action`  | Yes      | -       | Action to perform            |
| `--verbose` | No       | `false` | Enable verbose output        |
```

### Workflow Execution Pattern

When executing multi-step workflows, create a TODO list where each step references the relevant documentation:

```markdown
## TODO

- [ ] Step 1: Configure environment - see [workflow-setup.md](./references/workflow-setup.md#environment)
- [ ] Step 2: Build project - see [workflow-setup.md](./references/workflow-setup.md#build)
- [ ] Step 3: Deploy to staging - see [workflow-deployment.md](./references/workflow-deployment.md#staging)
- [ ] Step 4: Run validation - see [workflow-deployment.md](./references/workflow-deployment.md#validation)
- [ ] Step 5: Deploy to production - see [workflow-deployment.md](./references/workflow-deployment.md#production)
```

This ensures traceability and allows resuming workflows if interrupted.

## Validation Checklist

Before publishing a skill:

- [ ] `SKILL.md` has valid frontmatter with `name` and `description`
- [ ] `name` is 1-64 characters and matches its parent directory
- [ ] Name characters are lowercase alphanumeric or hyphens; no leading, trailing, or consecutive hyphens
- [ ] ASCII naming is treated as a local portability convention, not a Unicode prohibition in the format
- [ ] `description` is a non-empty string of 1-1024 characters
- [ ] Optional `compatibility` is a string of 1-500 characters
- [ ] Optional `metadata` maps string keys to string values
- [ ] Optional `license` reflects the owner's choice or references bundled terms
- [ ] Optional `allowed-tools` is a space-separated string with host support verified
- [ ] Portable frontmatter contains no nonstandard top-level fields
- [ ] `description` clearly states **WHAT** it does, **WHEN** to use it, and relevant **KEYWORDS**
- [ ] `description` is concise and keyword-dense (respects context budget)
- [ ] Body focuses on information Copilot wouldn't know from training data
- [ ] Body includes when to use, prerequisites (if applicable), and core instructions
- [ ] `## Gotchas` section present if skill involves non-obvious behavior, API quirks, or common traps
- [ ] Aim for under 500 lines and under 5,000 instruction tokens; separate this advice from format validation
- [ ] Detailed workflows have direct reference links where useful, without a mandatory step-count threshold
- [ ] Scripts include help documentation and error handling
- [ ] Relative paths used for all resource references
- [ ] No hardcoded credentials or secrets

### Reference Validation

Use the [skills-ref reference library](https://github.com/agentskills/agentskills/tree/main/skills-ref)
to validate a skill directory, not this instruction file. With an approved,
pinned version already installed, run the following from the directory
containing `my-skill`:

```text
skills-ref validate .\my-skill
```

This is the Windows spelling of the specification's relative-path example.
Use the equivalent path syntax on other platforms. Record the validator
version or commit and its actual results. Do not silently substitute versions
or install tooling just to validate documentation.

Reference validation checks frontmatter and naming, not editorial quality or
host behavior. Source reviewed on 2026-10-18 at commit `547831f3`.
The reviewed validator accepts empty `compatibility` and does
not check nested `metadata` value types. Check those specification constraints
explicitly; a successful validator result alone is insufficient.

Check boundary cases: names of 1, 64, and 65 characters; uppercase, digits,
invalid hyphens, and directory mismatch; descriptions of 0, 1, 1024, and 1025
characters; compatibility of 0, 1, 500, and 501 characters when present; and
non-string metadata values. Reject whitespace-only required strings.
Parse examples as YAML, check bundled references, and verify host discovery
separately. Report unavailable validation rather than claiming it passed.

## Related Resources

- [Agent Skills Specification](https://agentskills.io/specification)
- [Reference Validator Source](https://github.com/agentskills/agentskills/blob/547831f3a23724ba64a9b79bbf59c5e0bc8f2d1a/skills-ref/src/skills_ref/validator.py)
- [VS Code Agent Skills Documentation](https://code.visualstudio.com/docs/copilot/customization/agent-skills)
- [Reference Skills Repository](https://github.com/anthropics/skills)
- [Awesome Copilot Skills](https://github.com/github/awesome-copilot/blob/main/docs/README.skills.md)
