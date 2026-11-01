## Changelog tooling evaluation (Copilot CLI)

This evaluation targets a solo-owned, Windows-based repository using GitHub
Actions, label-heavy bot pull requests, and release-only changelog updates.

## `gh-changelog` verdict

[`gh-changelog`](https://github.com/chelnak/gh-changelog) is a functional fit
but a maintenance risk. Its latest release was
[`v0.15.3` on 2024-05-03](https://github.com/chelnak/gh-changelog/releases/tag/v0.15.3),
and its last default-branch commit was
[2024-09-04](https://github.com/chelnak/gh-changelog/commit/cd385e0c9128492b4a4ed227d1a90f5cedc195ef).
It has
[129 stars, an MIT license, and 14 open issues](https://api.github.com/repos/chelnak/gh-changelog).

It produces Keep a Changelog output, maps labels to sections, supports CI, and
publishes Windows AMD64 and ARM binaries
([release checksums](https://github.com/chelnak/gh-changelog/releases/download/v0.15.3/checksums.txt)).
Repository-local configuration is supported, although initialization remains
manual ([issue 120](https://github.com/chelnak/gh-changelog/issues/120)).

Open issues cover local configuration, preserving manual edits
([issue 104](https://github.com/chelnak/gh-changelog/issues/104)), and tag-range
handling. `--next-version` can reject valid maintenance versions and combine
tags from unrelated branches
([issue 145](https://github.com/chelnak/gh-changelog/issues/145)). Deterministic
or idempotent output is not documented.

## Alternatives

| Tool | Model | Maintenance and fit |
| --- | --- | --- |
| [Release Drafter](https://github.com/release-drafter/release-drafter/commit/03b926709c71605b56be5a0d40b1db063852f0a6) | Labels; repository YAML | Active 2026-10-09; native Action; low churn and effort |
| [GitHub generated notes](https://docs.github.com/en/repositories/releasing-projects-on-github/automatically-generated-release-notes) | Labels; `.github/release.yml` | Native; no feature-PR churn; very low effort |
| [GitHub Changelog Generator](https://github.com/github-changelog-generator/github-changelog-generator/commit/5a0cbdb6860ffc449e838541faf3f24e10d75722) | Labels and tags; repository config | Active 2026-03-18; Windows Ruby; medium effort |
| [git-cliff](https://github.com/orhun/git-cliff/commit/60e0be97e945f71148172675be82399d382c9677) | Commits; `cliff.toml` | Active 2026-09-18; Windows; medium effort |
| [Changie](https://github.com/miniscruff/changie/commit/e78b7fcae4fd76fc588b6442117ef99c39835e15) | Fragments; repository YAML | Active 2026-08-20; low conflicts; high effort |
| [release-please](https://github.com/googleapis/release-please/commit/fa67225b42d8133331a1b48e89640b60e9ca6a23) | Commits; repository JSON | Active 2026-10-05; release PR; high effort |
| [Towncrier](https://github.com/twisted/towncrier/commit/d7c67e747489a84691f1cfa18ea28b51c0f0e7ac) | Fragments; `pyproject.toml` | Active 2026-10-05; low conflicts; high effort |
| [conventional-changelog](https://github.com/conventional-changelog/conventional-changelog/commit/6ecad012487bc20e457a5bd45cc6710ec22651ff) | Commits; JavaScript config | Active 2026-10-06; Windows; medium effort |

## Recommendation

Use
[GitHub generated release notes](https://docs.github.com/en/repositories/releasing-projects-on-github/automatically-generated-release-notes)
as the source, then normalize it into `CHANGELOG.md` only in a release pull
request. It matches label-driven categorization and avoids bot-driven conflicts.
Its largest risk is the custom transformation needed for strict Keep a
Changelog and Markdown lint output.

Use GitHub Changelog Generator as the fallback. Its largest risk is the Ruby
runtime and additional maintenance surface.

## Verification limits

The research did not verify generated output by executing any candidate.
`gh-changelog` idempotence, exact Markdown lint compatibility, and milestone
filtering behavior therefore remain unverified.
