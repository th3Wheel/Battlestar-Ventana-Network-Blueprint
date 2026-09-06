# Chronicle Workflow Analysis and Starter Prompt Template (2026-06-04)

## Scope

- Workspace: Battlestar-Ventana-Network-Blueprint
- Chronicle pass 1: Recent cross-session analysis (7 to 30 day window)
- Chronicle pass 2: Repository-only follow-up for Battlestar-Ventana-Network-Blueprint (60 day window)

## Result Set A: Initial Chronicle Findings (Cross-Session)

### Observed patterns

- Session mix in recent window: VS Code Chat (9), Copilot Coding Agent (3), Copilot Code Review (1).
- VS Code Chat contained most conversational turns.
- Prompt style alternates between:
  - very short directives (for example: "do so", "pull request", "continue with the plan to commit")
  - occasional long context payloads when starting a task or forwarding review context.
- Long sessions were present (for example, one 30-turn session and one 10-turn session).
- Checkpoint usage was effectively absent in sampled sessions (0 compaction checkpoints).

### Practical implications

- Direction is clear, but frequent short follow-ups can create extra steering turns.
- Long sessions without compaction increase context accumulation.
- Coding Agent and Code Review workflows can inject very large prompt payloads; scoping matters.

## Result Set B: Follow-Up Chronicle (Repository-Only)

### Query scope

- Repository filter: `repository ILIKE '%Battlestar-Ventana-Network-Blueprint%'`
- Time window: last 60 days

### Session snapshot

- 3 sessions found:
  - feat/dotfiles-fzf-integration: 1 turn, 0 minutes
  - chore/sentry-powershell-setup: 10 turns, 79 minutes
  - chore/sentry-powershell-setup: 3 turns, 5 minutes

### Prompt style metrics (repo-only)

- Total turns: 14
- Average prompt length: 62.79 chars
- Short prompts (<=20 chars): 6 (42.9%)
- Long prompts (>=300 chars): 1 (7.1%)
- Directive-like prompts detected: 5 (for example: "do so", "pull request", "continue with the plan to commit", "wire it properly")

### Additional notes

- Checkpoints in these repo sessions: 0
- `session_files` returned no rows for these specific session IDs in cloud data for this pass, so file-level tool frequency could not be expanded from session-store data alone.

## Consolidated Guidance (From Both Passes)

1. Keep your directive speed, but front-load acceptance criteria in the first message.
2. Split planning, implementation, and PR-finalization into separate threads when a task exceeds about 8 to 10 turns.
3. Compact before pivot points (for example, before "prepare PR" or "switch modes") to reduce context drag.
4. Use Coding Agent for tightly bounded tasks with explicit file targets and done criteria.
5. Reuse a standardized starter prompt so short follow-up commands remain effective without re-explaining constraints.

## Best Starter Prompt Template (Tailored to Your Command Style)

Use this as your opening message for implementation tasks:

```md
Task: <one-sentence objective>

Repository context:
- Branch: <branch name>
- Scope paths: <path1>, <path2>, <path3>
- Out of scope: <path or concern>

Constraints:
- Follow existing repo standards and instructions.
- Make minimal, surgical edits only.
- Do not change unrelated files.

Execution mode:
1. Analyze relevant files and summarize planned edits in 3-6 bullets.
2. Implement changes directly.
3. Run the most relevant validation (tests/lint/check) for touched files.
4. Report exact files changed and why.

Done criteria:
- <behavior/result 1>
- <behavior/result 2>
- <validation proof expected>

Output format:
- Summary
- Files changed
- Validation results
- Optional: proposed commit message

If anything is ambiguous, ask one concise clarification question. Otherwise proceed.
```

## Fast Variants You Can Paste

### PR comment fix kickoff

```md
Fix all actionable PR comments for this branch.
Scope: <files>
Rules: minimal edits, keep behavior stable, follow repo instructions.
Then run relevant checks and provide a commit-ready summary.
```

### Finalization command after implementation

```md
Proceed to PR-ready finalization:
1. Re-run validations for touched files.
2. Summarize changes by file.
3. Draft concise PR description with risk and test notes.
```
