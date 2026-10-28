## Changelog tooling research

Evaluates changelog-generation tooling for this repository, which is
solo-owned, Windows-based, and uses GitHub Actions, label-heavy bot pull
requests, and release-only changelog updates.

## Current conclusion

Prefer GitHub generated release notes as the source, normalized into
`CHANGELOG.md` only within a release pull request. GitHub Changelog Generator
is the fallback. See the contributions below for the supporting evidence and
risks.

## Contributions

- [Copilot CLI evaluation](copilot-cli.md)

## Status

No tooling has been adopted, and no candidate output has been executed or
validated in this repository.
