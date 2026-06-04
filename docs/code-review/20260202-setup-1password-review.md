# Code Review: setup-1password.sh

**Ready for Production**: No
**Critical Issues**: 1

## Priority 1 (Must Fix) ⛔

- **Syntax is broken before it even runs.** There is an `a` literal on line 7 between `set -e` and the `echo` statement which causes the shell to exit immediately and prevents the rest of the script from executing. Remove the stray character so the script can start reliably.
- **Credentials leak risk.** `op connect server create ... > 1password-credentials.json` writes the sensitive Connect server key to the repository root with the default umask (typically 022) which leaves it world-readable. This file contains long-lived credentials and must be restricted: run the command into a secure temporary file (`mktemp`), `chmod 600` it immediately, and move it into a git-ignored path (or use `op connect server create --output` with `umask 077`).

## Recommended Changes

- Delete the stray `a` near the top so the interpreter can parse the script.
- Wrap the credential creation in a temporary file, enforce `chmod 600`, and avoid leaving the secret in a committed path (use `.gitignore` or a configured secrets store). Document where the credential file lives and how it should be rotated so it is not accidentally checked in.
