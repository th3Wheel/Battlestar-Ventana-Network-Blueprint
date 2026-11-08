# Changelog

Changelog maintenance is temporarily paused to reduce documentation churn.

## Unreleased

### Changed

- Harden `bootstrap/ssh_key_bootstrap.yml`. The 1Password password is now
  resolved once by a `no_log` `set_fact` task instead of a lazy play var that
  re-ran the lookup on every use. The assert treats empty or `None` lookup
  results as failures. `public_key_path` is expanded with `expanduser`, because
  `expect` does not run a shell and a bare `~` was never expanded. The `expect`
  task also gets `no_log`, and `debug` uses its fully qualified name. This
  approved correction is recorded while general maintenance remains paused.

## Maintenance Policy

When changelog maintenance resumes:

- Record only user-visible changes.
- Group entries by release.
- Avoid logging formatting-only or bulk refactor churn.
