import { spawnSync } from 'node:child_process';
import { tmpdir } from 'node:os';
import { join } from 'node:path';
import { describe, expect, it } from 'vitest';

// `*/settings.local.json` is per-machine: a person's own permissions and paths. It must
// never be committed, whichever agent's directory it sits in.

const git = (...args: string[]) =>
  spawnSync('git', args, { encoding: 'utf8', cwd: new URL('..', import.meta.url) });

describe('per-machine settings.local.json', () => {
  it('is not tracked anywhere in the repository', () => {
    const tracked = git('ls-files').stdout.split(/\r?\n/);
    expect(tracked.filter((file) => /(^|\/)settings\.local\.json$/.test(file))).toEqual([]);
  });

  it.each([
    '.claude/settings.local.json',
    '.gemini/settings.local.json',
    'any/nested/dir/settings.local.json',
  ])('is ignored by the repository itself: %s', (file) => {
    // Point the user-level excludes at a file that does not exist, so a developer's own
    // global ignore cannot make this pass on their machine and fail everywhere else.
    const result = git(
      '-c',
      `core.excludesFile=${join(tmpdir(), 'no-such-excludes-file')}`,
      'check-ignore',
      '--no-index',
      '-q',
      file,
    );
    expect(result.status).toBe(0);
  });
});
