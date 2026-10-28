---
name: plan-eslint-markdown-green
description: plan-eslint-markdown-green
disable-model-invocation: true
---
## Plan: Resolve Markdown ESLint findings

Run `npm run lint:md` to inspect Markdown diagnostics from the
`@eslint/markdown` recommended configuration. Fix content-level errors rather
than weakening the shared ESLint configuration.

The Markdown ESLint plugin does not provide formatting rules or automatic
formatting fixes. Use Prettier only when formatting is requested, and do not
assume that its rules cover every check previously provided by markdownlint.

Verify changes with `npm run lint:md`; use `npm run lint` for the full
repository lint check.
