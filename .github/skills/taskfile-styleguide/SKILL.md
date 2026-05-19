---
name: taskfile-styleguide
description: "Enforces the official Taskfile.dev style guide when creating or editing Taskfile.yml files. Use when writing a new Taskfile, reviewing an existing Taskfile for style compliance, adding tasks, variables, or includes, or fixing Taskfile formatting issues. Covers section ordering, indentation, variable naming, task naming, namespace conventions, and command complexity guidelines."
---

# Taskfile Style Guide

Applies the official [Taskfile.dev style guide](https://taskfile.dev/docs/styleguide) when creating or editing `Taskfile.yml` files.

## When to Use This Skill

- Creating a new `Taskfile.yml` from scratch
- Reviewing or refactoring an existing Taskfile for style compliance
- Adding tasks, variables, includes, or environment configuration
- Fixing formatting complaints or inconsistencies in a Taskfile
- Generating task names, variable names, or namespace structures

## Style Rules

### 1. Section Ordering

Always use this top-to-bottom ordering for the main sections:

```yaml
version:
includes:
# optional configurations (output, silent, method, run, etc.)
vars:
env: # followed or replaced by dotenv
tasks:
```

### 2. Two-Space Indentation

YAML indentation must be **two spaces**. Never use four spaces or tabs.

```yaml
# bad
tasks:
    foo:
        cmds:
            - echo 'foo'

# good
tasks:
  foo:
    cmds:
      - echo 'foo'
```

### 3. Separate Main Sections with Empty Lines

Each top-level section must be separated by a blank line.

```yaml
# bad
version: '3'
includes:
  docker: ./docker/Taskfile.yml
vars:
  FOO: bar
tasks:
  # ...

# good
version: '3'

includes:
  docker: ./docker/Taskfile.yml

vars:
  FOO: bar

tasks:
  # ...
```

### 4. Separate Tasks with Empty Lines

Individual task definitions must also be separated by blank lines.

```yaml
# bad
tasks:
  foo:
    cmds:
      - echo 'foo'
  bar:
    cmds:
      - echo 'bar'

# good
tasks:
  foo:
    cmds:
      - echo 'foo'

  bar:
    cmds:
      - echo 'bar'
```

### 5. Uppercase Variable Names

All variable names in `vars:` and `env:` must use **SCREAMING_SNAKE_CASE**.

```yaml
# bad
vars:
  binary_name: myapp

# good
vars:
  BINARY_NAME: myapp
```

### 6. No Whitespace Inside Template Delimiters

Variable references must use `{{.VAR}}` — no spaces inside the braces. This matches Go template conventions.

```yaml
# bad
cmds:
  - echo '{{ .MESSAGE }}'

# good
cmds:
  - echo '{{.MESSAGE}}'
```

### 7. Kebab-Case Task Names

Task names use **kebab-case** (lowercase words separated by hyphens), not snake_case or camelCase.

```yaml
# bad
tasks:
  do_something_fancy:
    cmds:
      - echo 'Do something'

# good
tasks:
  do-something-fancy:
    cmds:
      - echo 'Do something'
```

### 8. Colon as Namespace Separator

Use a colon (`:`) to separate namespace and task name. This is also the convention applied automatically by `includes:`.

```yaml
# good
tasks:
  docker:build:
    cmds:
      - docker build .

  docker:run:
    cmds:
      - docker compose up
```

### 9. Prefer External Scripts Over Multi-Line Commands

Move complex shell logic into standalone scripts. Keep `cmds:` entries short and readable.

```yaml
# bad
tasks:
  build:
    cmds:
      - |
        for i in $(seq 1 10); do
          echo $i
          echo "some other complex logic"
        done

# good
tasks:
  build:
    cmds:
      - ./scripts/build.sh
```

## Gotchas

- **`version:` is required** — always include `version: '3'` (or the latest supported version) as the first key.
- **Template syntax is Go templates** — `{{.VAR}}` not `${VAR}` or `$VAR`. Using the wrong syntax silently produces empty output.
- **Included Taskfiles automatically namespace tasks** — a task `build` in `./docker/Taskfile.yml` included as `docker` becomes `docker:build`. Do not manually prefix if using `includes:`.
- **`env:` vs `vars:`** — `env:` values are exported to child processes; `vars:` values are only available inside Task templates. Use `env:` for values that scripts need to read.

## Taskfile Features Reference

Derived from the [Taskfile Guide](https://taskfile.dev/docs/guide).

### Running Taskfiles

- Task searches for `Taskfile.yml` (and variants) in the current directory, walking up the tree like `git`.
- `--taskfile <path>` — specify a file explicitly.
- `--dir <path>` — set the working directory.
- `-g` / `--global` — run from `$HOME`.
- `-t -` — read Taskfile from stdin.
- `--` — everything after is forwarded as `.CLI_ARGS` to the task.

### Variable Precedence (highest → lowest)

1. Task definition `vars:`
2. Caller-passed vars (`task foo VAR=val`)
3. Included Taskfile vars
4. Inclusion vars
5. Global `vars:`
6. Environment variables

Use `sh:` inside `vars:` to capture shell output (dynamic vars). Use `ref:` to pass non-string types between tasks.

```yaml
vars:
  GIT_COMMIT:
    sh: git log -n 1 --format=%h
```

### Dependencies and Calling Tasks

- `deps:` runs listed tasks **in parallel** before the current task.
- Use `cmds: - task: foo` for **serial** execution.
- `failfast: true` — stop on first dependency failure.
- `run: once` — deduplicate repeated calls to the same task within a run.
- `run: when_changed` — re-run only when vars differ between calls.

```yaml
tasks:
  build:
    deps: [lint, test] # parallel
    cmds:
      - task: compile # serial, after deps
      - ./scripts/package.sh
```

### Preventing Unnecessary Work

- `sources:` + `generates:` — skip task if outputs are newer than inputs (checksum or timestamp).
- `status:` — run arbitrary commands; skip task if all exit `0`.
- `preconditions:` — fail (not skip) the task if conditions are unmet; use for hard requirements.
- `requires: vars:` — enforce that named variables are set, with optional `enum:` allowlists.

```yaml
tasks:
  build:
    sources:
      - "**/*.go"
    generates:
      - bin/app
    cmds:
      - go build -o bin/app .
```

### Looping

`for:` supports multiple sources:

```yaml
tasks:
  lint-files:
    for:
      - file1.go
      - file2.go
    cmds:
      - golint {{.ITEM}}

  # loop over a variable (comma or newline separated)
  tag-images:
    for:
      var: IMAGES
      split: ","
    cmds:
      - docker tag app {{.ITEM}}
```

Also supports `sources:`, `generates:`, and matrix patterns.

### Deferred Cleanup

`defer:` guarantees a command runs when the task exits, even on failure.

```yaml
tasks:
  deploy:
    defer: ./scripts/cleanup.sh
    cmds:
      - ./scripts/deploy.sh
```

### Output Modes

Set at the top level or per-task:

```yaml
output: group      # buffer and print together (good for parallel tasks)
output: prefixed   # prefix each line with task name
output: interleaved  # default, real-time
```

### Other Useful Features

- `prompt:` — require user confirmation before running a dangerous task.
- `platforms:` — restrict a task to specific OS (`linux`, `darwin`, `windows`) or arch.
- `watch: true` + `sources:` — re-run the task when source files change.
- Wildcard task names: `deploy:*:*` captures segments in `.MATCH`.
- `silent: true` — suppress command echo for a task or globally.

## References

- [Taskfile Style Guide](https://taskfile.dev/docs/styleguide)
- [Taskfile Guide](https://taskfile.dev/docs/guide)
- [Taskfile Variables Reference](https://taskfile.dev/docs/guide#variables)
- [Includes](https://taskfile.dev/docs/guide#including-other-taskfiles)
