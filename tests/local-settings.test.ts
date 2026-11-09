import { spawnSync } from 'node:child_process';
import { copyFileSync, mkdirSync, mkdtempSync, writeFileSync } from 'node:fs';
import { tmpdir } from 'node:os';
import { join } from 'node:path';
import { fileURLToPath } from 'node:url';
import { describe, expect, it } from 'vitest';

// `*/settings.local.json` is per-machine: a person's own permissions and paths. It must
// never be committed, whichever agent's directory it sits in. Several independent checks
// guard that, so no single mechanism (a .gitignore line, a local exclude) is relied on alone.

const REPO = new URL('..', import.meta.url);
const NO_GLOBAL_EXCLUDES = ['-c', `core.excludesFile=${join(tmpdir(), 'no-such-excludes-file')}`];

const git = (cwd: string | URL, ...args: string[]) => spawnSync('git', args, { encoding: 'utf8', cwd });

// The file holding the rule git applies to `file`, or undefined when nothing ignores it.
// The developer's global excludes are switched off so they cannot make this pass on one
// machine and fail on another; .git/info/exclude cannot be switched off, which is why the
// source of the match is read instead of only the exit status.
function ignoringSource(cwd: string | URL, file: string): string | undefined {
  const result = git(cwd, ...NO_GLOBAL_EXCLUDES, 'check-ignore', '--no-index', '-v', file);
  // Verbose output is "<source>:<line>:<pattern><TAB><path>".
  return result.status === 0 ? result.stdout.match(/^(.+?):\d+:/)?.[1] : undefined;
}

const isGitignore = (source: string | undefined) =>
  source !== undefined && /(^|[\\/])\.gitignore$/.test(source);

const SAMPLES = [
  '.claude/settings.local.json',
  '.gemini/settings.local.json',
  'any/nested/dir/settings.local.json',
];

describe('per-machine settings.local.json', () => {
  it('is not tracked anywhere in the repository', () => {
    const tracked = git(REPO, 'ls-files').stdout.split(/\r?\n/);
    expect(tracked.filter((file) => /(^|\/)settings\.local\.json$/.test(file))).toEqual([]);
  });

  it.each(SAMPLES)('is ignored by git, by whatever mechanism: %s', (file) => {
    expect(ignoringSource(REPO, file)).toBeDefined();
  });

  it.each(SAMPLES)('is ignored by a .gitignore rule the repository itself carries: %s', (file) => {
    expect(isGitignore(ignoringSource(REPO, file))).toBe(true);
  });

  it('is refused by `git add` in a repository using this .gitignore', () => {
    // A fresh repository with only the real .gitignore: an accidental `git add` must fail
    // and stage nothing. (A deliberate `git add -f` is what the tracked-file check catches.)
    const dir = mkdtempSync(join(tmpdir(), 'lst-add-'));
    git(dir, 'init', '-q');
    copyFileSync(fileURLToPath(new URL('../.gitignore', import.meta.url)), join(dir, '.gitignore'));
    mkdirSync(join(dir, '.claude'));
    writeFileSync(join(dir, '.claude', 'settings.local.json'), '{}');

    const add = git(dir, ...NO_GLOBAL_EXCLUDES, 'add', '.claude/settings.local.json');
    expect(add.status).not.toBe(0);
    expect(git(dir, 'ls-files').stdout.trim()).toBe('');
  });

  it('tells a .git/info/exclude entry apart from a .gitignore rule', () => {
    // No .gitignore, only a clone-local exclude: git ignores the file, but the repository
    // has not declared the rule, so the check above must not accept it.
    const dir = mkdtempSync(join(tmpdir(), 'lst-exclude-'));
    git(dir, 'init', '-q');
    mkdirSync(join(dir, '.git', 'info'), { recursive: true });
    writeFileSync(join(dir, '.git', 'info', 'exclude'), '**/settings.local.json\n');

    const source = ignoringSource(dir, '.claude/settings.local.json');
    expect(source).toBeDefined();
    expect(isGitignore(source)).toBe(false);
  });
});
