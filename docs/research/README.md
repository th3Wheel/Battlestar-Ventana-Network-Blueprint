## Research

This directory holds research notes that inform decisions but are not
themselves specifications or runbooks.

## Structure

Each research topic gets its own folder, and each researching agent or author
contributes a separate file inside that folder.

```text
docs/research/
  <topic-slug>/
    README.md        # topic summary and index of contributions
    <agent-slug>.md  # one file per agent or author
```

## Conventions

- Use kebab-case for topic folders and contribution files.
- Name each contribution file after the agent or author that produced it, such
  as `copilot-cli.md`.
- Keep every contribution self-contained, including its own sources and any
  limits on what was verified.
- Record shared conclusions in the topic `README.md` rather than duplicating
  them across contributions.

## Topics

- [Changelog tooling](changelog-tooling/README.md)
