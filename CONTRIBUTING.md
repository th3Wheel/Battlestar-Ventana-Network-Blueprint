## Contributing

Read the repository guidance in [`AGENTS.md`](./AGENTS.md) before making
changes. Check any applicable instructions under `.github/instructions/` and
use the relevant skill under `.agents/skills/` for specialized workflows.

### Propose a change

1. Create a focused topic branch from the repository's default branch.
2. Keep each change related to one purpose and update affected documentation.
3. Do not include credentials, private network details, or other secrets in
   issues, logs, commits, or pull requests.
4. Use the issue forms in `.github/ISSUE_TEMPLATE/` to report a bug or propose
   a feature.

### Validate a change

From the repository root, run:

1. `npm ci`
2. `npm test`
3. `npm run lint`

For MCP configuration changes, also run `npm run mcp:sync-check`. See
[`readme.md`](./readme.md) for tool prerequisites and Python/Ansible setup.

### Open a pull request

Use [the pull request template](./.github/PULL_REQUEST_TEMPLATE.md). Describe
the purpose, affected areas, validation results, and any network or security
impact. A person must review changes to network configuration, infrastructure,
and MCP endpoints or tool access before merge.
