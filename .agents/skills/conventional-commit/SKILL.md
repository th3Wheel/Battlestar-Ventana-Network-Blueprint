---
name: conventional-commit
description: Prompt and workflow for generating conventional commit messages using a structured XML format. Guides users to create standardized, descriptive commit messages in line with the Conventional Commits specification, including instructions, examples, and validation.
disable-model-invocation: true
---
### Instructions

```xml
<metadata>
	<description>This file contains a prompt template for generating conventional commit messages. It provides instructions, examples, and formatting guidelines to help users write standardized, descriptive commit messages in accordance with the Conventional Commits specification.</description>
	<note>Use this template to generate clear, conventional commit messages for your changes.</note>
</metadata>
```

### Workflow

**Follow these steps:**

1. Run `git status` to review changed files. If there are no changes, tell the user and do not generate a commit message. If the changes cover unrelated concerns, recommend splitting them into separate commits.
2. Inspect all changes before staging: run `git diff` for unstaged changes and `git diff --cached` for staged changes. Confirm which files and changes belong in this commit.
3. Stage only the reviewed files for this commit with `git add <file>`.
4. Construct your commit message using the following XML structure.
5. Present the commit message and a corresponding `git commit` command for the user to review. Do not execute the command unless the user explicitly confirms.

```bash
git commit -m "type[!][(scope)]: description" -m "body" -m "footer"
```

### Commit Message Structure

```xml
<commit-message>
	<type>feat|fix|docs|style|refactor|perf|test|build|ci|chore|revert</type>
	<scope>Optional: a noun for the affected area, e.g. parser; omit this element if no scope applies.</scope>
	<description>A short, imperative summary of the change</description>
	<body>(optional: more detailed explanation)</body>
	<footer>(optional: e.g. BREAKING CHANGE: details, or issue references)</footer>
	<breaking-change>Optional: add ! after the type or scope for a breaking change, e.g. feat!: ... or feat(api)!: ...</breaking-change>
</commit-message>
```

### Examples

```xml
<examples>
	<example>feat(parser): add ability to parse arrays</example>
	<example>fix(ui): correct button alignment</example>
	<example>docs: update README with usage instructions</example>
	<example>refactor: improve performance of data processing</example>
	<example>chore: update dependencies</example>
	<example>feat!: send email on registration (BREAKING CHANGE: email service required)</example>
</examples>
```

### Validation

```xml
<validation>
	<type>Must be one of the allowed types. See <reference>https://www.conventionalcommits.org/en/v1.0.0/#specification</reference></type>
	<scope>Optional, but recommended for clarity.</scope>
	<description>Required. Use the imperative mood (e.g., "add", not "added").</description>
	<body>Optional. Use for additional context.</body>
	<footer>Use for breaking changes or issue references.</footer>
</validation>
```

### Final Step

```xml
<final-step>
	<cmd>git commit -m "type[!][(scope)]: description" -m "body" -m "footer"</cmd>
	<note>Replace the placeholders with your message. Omit the optional !, scope, body, or footer when not applicable; use one -m flag per message paragraph. Include BREAKING CHANGE: in the footer when needed. Present the command for user review and execute it only after explicit confirmation.</note>
</final-step>
```
