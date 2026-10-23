## Agent Skills guideline alignment plan

Status: Completed on 2026-10-18 with reference-runtime validation unavailable.
Source reviewed: 2026-10-18.

### Goal and scope

Update the [primary guideline](../.github/instructions/agent-skills.instructions.md)
to accurately describe the [Agent Skills specification][spec], while keeping
useful repository conventions clearly separate from the portable format.

Preserve existing uncommitted edits. Do not migrate skill directories, rewrite
existing skills, install tools, change host configuration, or add CI in this
documentation update.

### Evidence and source precedence

- The specification is authoritative for portable format requirements.
- Official host documentation governs discovery paths and host extensions.
- Repository preferences may be stricter, but must be labeled as local policy.
- The Agent Skills MCP search returned the specification's frontmatter rules.
  The complete specification was also retrieved directly.
- Context7 discovery returned similarly named skill collections, not the
  authoritative specification. Do not substitute those collections for it.
- The [secondary guideline][secondary] had the same targeting pattern and
  shared content, except for the primary's extra nonstandard fields.
  Updated both to avoid conflicting instructions; the copies now match.

### Required corrections

| Area | Current gap | Planned correction |
| --- | --- | --- |
| Standard fields | Includes `id`, `applyTo`, and `disable-model-invocation`; omits three standard optional fields | Document required `name` and `description`, plus optional `license`, `compatibility`, `metadata`, and experimental `allowed-tools` |
| Extensions | Presents extra fields as generally portable | Remove `id` recommendation; use string-valued `metadata` for custom identifiers; describe host-specific fields separately only with host documentation |
| Names | Omits digits, minimum length, directory matching, and hyphen restrictions | Document 1-64 characters, matching parent directory, no leading/trailing hyphens, and no consecutive hyphens |
| Descriptions | Requires 10 characters and single quotes | Correct to 1-1024 characters; require valid YAML, not a particular quoting style |
| Compatibility | Missing | Explain optional 1-500-character environment requirements |
| Metadata | Missing | Specify a mapping of string keys to string values; quote numeric-looking versions |
| Tool permissions | Missing standard field | Explain space-separated `allowed-tools`, experimental support, and host-dependent behavior; do not imply portable enforcement |
| Licensing | Requires downloading Apache 2.0 | Make licensing optional; use the owner's chosen license or bundled terms; do not assign a license automatically |
| Resources | Treats `assets/` as immutable and never loaded | Explain that assets may include templates, images, and data; `templates/` is an allowed local convention, not a standard directory requirement |
| Discovery | Makes absolute activation and context-cost claims | Explain progressive disclosure without guarantees that a description always activates or that unused skills consume no context |
| Body limits | Calls 500 lines a hard maximum; requires splitting workflows over five steps | Present under 500 lines and under 5,000 tokens as authoring guidance; label the 200-line and five-step heuristics as local advice or remove them |
| References | Omits shallow-reference guidance | Use paths relative to the skill root and direct links from `SKILL.md`; avoid deeply nested reference chains |
| Validation | Only a manual checklist | Add the documented `skills-ref validate` workflow and distinguish schema validation from editorial and host checks |

The reference validator at commit `547831f3a23724ba64a9b79bbf59c5e0bc8f2d1a`
supports Unicode alphanumeric names, NFKC normalization, and a lowercase check.
ASCII lowercase letters, digits, and hyphens remain a conservative repository
convention, not a specification restriction.

### Implementation sequence

1. [x] Establish the editing baseline.
   Review current diffs for both guidelines, their applicable instructions,
   references, and existing documentation validation commands.
   Confirm whether the secondary copy must remain synchronized.
   Dependency: maintainer approval of this plan.
2. [x] Separate portable requirements from local and host conventions.
   Retain the instruction file's own `description` and `applyTo` frontmatter:
   those configure this guideline, not the skills it describes.
   Keep repository discovery order explicitly local, without moving directories.
   Dependency: step 1.
3. [x] Correct field tables, explanations, and examples.
   Apply every frontmatter and licensing correction above. Include a minimal
   example and a complete optional-fields example with consistent types.
   Resolve the name-character ambiguity against the reference validator.
   Dependency: step 2.
4. [x] Correct body, resource, and loading guidance.
   Preserve useful workflow and security advice, but label editorial preferences.
   Remove unsupported immutable-asset and automatic-activation guarantees.
   Dependency: step 2.
5. [x] Refresh validation and related documentation.
   Align the checklist with the revised rules and link directly to the
   specification. Update the secondary copy if confirmed maintained.
   Add a concise Changed entry to [the changelog](../CHANGELOG.md).
   Dependency: steps 3 and 4.
6. [x] Verify and hand off.
   Run the existing targeted Markdown checks for edited documentation.
   Validate extracted example skills with a pinned reference-validator version
   if already available; otherwise record that validation is unavailable and
   request approval before introducing tooling. Review the final diff for
   preservation of user edits and absence of unrelated changes.
   Dependency: step 5.

### Acceptance criteria

- [x] All six standard fields have accurate required/optional status and types.
- [x] No host extension is presented as a portable specification field.
- [x] Documented boundary checks cover names of 1, 64, and 65 characters, digits,
  uppercase, invalid hyphens, and directory/name mismatch.
- [x] Documented boundary checks cover descriptions of 0, 1, 1024, and 1025 characters;
  compatibility of 0, 1, 500, and 501 characters when present; and non-string
  metadata values.
- [x] Examples parse as YAML; reference validation is unavailable, as recorded
  below. Constraints not enforced by the reviewed validator are documented.
- [x] License selection remains the owner's decision.
- [x] Resource layout permits optional directories without inventing restrictions.
- [x] Guidance distinguishes format requirements, recommendations, host behavior,
  and repository policy.
- [x] All revised local links resolve and targeted documentation checks pass,
  or unavailable checks are explicitly reported.
- [x] No existing skills, dependencies, host settings, or user edits are changed
  incidentally.

### Verification results

- ESLint 10.13.0 passed for the two guidelines, this plan, and the changelog,
  using the explicit project configuration:
  `.\node_modules\.bin\eslint.cmd --config .\eslint.config.ts` followed by
  the four edited document paths.
- Installed Prettier 3.9.10 parsed ten YAML blocks, including both instruction
  frontmatters and all fenced YAML examples. No packages were installed.
- Local document links resolve; illustrative skill-resource links inside
  fenced examples were excluded because those files are examples, not bundles.
- The guideline copies match, their portable field tables contain exactly the
  six specification fields, and the identified obsolete claims are absent.
- Changed-file whitespace checks passed with `git diff --check`.
- Reference-validator source was reviewed at the pinned commit above. It
  accepts empty compatibility strings and does not validate nested metadata
  value types; both gaps are now explicit in the guidelines.
- `skills-ref` was not found on PATH. The project Python runtime at
  `.venv\Scripts\python.exe` failed with a sandbox permission denial when
  spawning its interpreter. It was not retried through another path.
- Reference-validator execution, example validation through that executable,
  and executable boundary tests were **not run**. Source inspection and
  documented boundary expectations are not runtime test results.
- Host activation was not tested. No skill directories, application code,
  dependencies, or host settings were changed.
- The approved changelog entry was added as a specific exception while
  preserving the existing general maintenance pause.

### Boundary expectations reviewed against the specification

These are documented acceptance expectations, not executed validator tests.

| Field | Input | Expected result |
| --- | --- | --- |
| Name | 1 or 64 permitted characters, matching directory | Accept |
| Name | 65 characters | Reject |
| Name | Lowercase letters and digits, such as `pdf2-text` | Accept |
| Name | Uppercase, leading/trailing hyphen, or consecutive hyphens | Reject |
| Name | Different parent directory name | Reject |
| Description | Empty or whitespace-only | Reject |
| Description | 1 or 1024 non-empty characters | Accept |
| Description | 1025 characters | Reject |
| Compatibility | Absent | Accept |
| Compatibility | Empty string | Reject under specification; reviewed validator misses this |
| Compatibility | 1 or 500 characters | Accept |
| Compatibility | 501 characters | Reject |
| Metadata | String keys and string values | Accept |
| Metadata | Numeric, boolean, or nested non-string values | Reject under specification; reviewed validator misses this |

### Ownership and next action

Maintainer: review the completed documentation diff. To enable the deferred
Python-based checks, update sandbox policy for the project Python runtime and
approve a pinned reference-validator installation if one is required.
No tooling or sandbox-policy changes are part of this documentation update.

No implementation builds or application test suites are needed for this
documentation-only change.

[spec]: https://agentskills.io/specification
[secondary]: ../.github/instructions/doNotLint/agent-skills.instructions.md
