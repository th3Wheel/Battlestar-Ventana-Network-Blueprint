import { spawnSync } from 'node:child_process';
import { mkdtempSync, writeFileSync } from 'node:fs';
import { devNull, tmpdir } from 'node:os';
import { join } from 'node:path';
import { fileURLToPath } from 'node:url';
import { describe, expect, it } from 'vitest';
import {
  annotation,
  findViolations,
  loadPolicy,
  parsePolicy,
  trackedFiles,
  type Policy,
} from '../scripts/check-local-files.ts';

const SCRIPT = fileURLToPath(new URL('../scripts/check-local-files.ts', import.meta.url));
const BACKSLASH = String.fromCharCode(92);

const policy: Policy = {
  forbidden: [
    { pattern: '**/settings.local.json', reason: 'settings' },
    { pattern: '**/*.local.*', reason: 'local' },
    { pattern: '**/.env.*', reason: 'env' },
    { pattern: '**/.env', reason: 'env' },
  ],
  allowed: [{ path: '**/.env.example', reason: 'template' }],
};
const flagged = (...files: string[]) => findViolations(files, policy).map((v) => v.file);

describe('findViolations', () => {
  it('flags per-machine settings at the root and in any directory', () => {
    expect(flagged('settings.local.json', '.claude/settings.local.json', 'a/b/c/settings.local.json')).toEqual([
      'settings.local.json',
      '.claude/settings.local.json',
      'a/b/c/settings.local.json',
    ]);
  });

  it('flags any *.local.* file whatever its extension', () => {
    expect(flagged('config.local.yml', 'docs/notes.local.md', 'x/y.local.toml', 'a.local.b.c')).toHaveLength(4);
  });

  it('flags env files but lets the template through', () => {
    expect(flagged('.env', 'deploy/.env.production', '.env.example', 'deploy/.env.example')).toEqual([
      '.env',
      'deploy/.env.production',
    ]);
  });

  it('does not flag ordinary files or look-alikes', () => {
    expect(
      flagged('README.md', 'config/vlan-registry.yaml', 'local-notes.md', 'localhost.json', 'src/local/a.ts')
    ).toEqual([]);
  });

  it('normalizes Windows separators and a leading ./', () => {
    expect(flagged(`.claude${BACKSLASH}settings.local.json`, './a.local.json')).toEqual([
      '.claude/settings.local.json',
      'a.local.json',
    ]);
  });

  it('reports which rule matched and why', () => {
    expect(findViolations(['.claude/settings.local.json'], policy)).toEqual([
      { file: '.claude/settings.local.json', pattern: '**/settings.local.json', reason: 'settings' },
    ]);
  });
});

describe('parsePolicy', () => {
  it.each([
    ['not an object', []],
    ['missing allowed', { forbidden: [{ pattern: 'a', reason: 'b' }] }],
    ['empty forbidden list', { forbidden: [], allowed: [] }],
    ['forbidden rule without a reason', { forbidden: [{ pattern: 'a' }], allowed: [] }],
    ['forbidden rule with a blank pattern', { forbidden: [{ pattern: ' ', reason: 'b' }], allowed: [] }],
    ['allowed rule without a reason', { forbidden: [{ pattern: 'a', reason: 'b' }], allowed: [{ path: 'x' }] }],
  ])('rejects a malformed policy: %s', (_name, raw) => {
    expect(() => parsePolicy(raw)).toThrow();
  });

  // The matcher understands *, ** and ? only. A rule written in any other glob syntax would
  // silently never match, so it must be refused when the policy loads, not ignored.
  it.each(['**/*.[Pp][Ee][Mm]', '**/*.{pem,key}', '**/!(keep).env', '**/+(a|b).env', `a${BACKSLASH}*`])(
    'rejects unsupported glob syntax in a forbidden pattern: %s',
    (pattern) => {
      expect(() => parsePolicy({ forbidden: [{ pattern, reason: 'r' }], allowed: [] })).toThrow(/unsupported glob/);
    }
  );

  it('rejects unsupported glob syntax in an allowed path too', () => {
    expect(() =>
      parsePolicy({ forbidden: [{ pattern: 'a', reason: 'r' }], allowed: [{ path: '*.{a,b}', reason: 'r' }] })
    ).toThrow(/unsupported glob/);
  });

  it('accepts a well-formed policy', () => {
    expect(parsePolicy(policy)).toEqual(policy);
  });
});

describe('the repository policy', () => {
  const real = loadPolicy();

  it('forbids the per-machine settings and *.local.* files this rule exists for', () => {
    const patterns = real.forbidden.map((rule) => rule.pattern);
    expect(patterns).toContain('**/settings.local.json');
    expect(patterns).toContain('**/*.local.*');
  });

  it('keeps the .env.example template trackable', () => {
    expect(findViolations(['.env.example'], real)).toEqual([]);
    expect(findViolations(['.env', '.env.production'], real)).toHaveLength(2);
  });

  it.each(['.envrc', '.envbackup', 'deploy/.envrc', 'deploy/.env.production', 'deploy/.env'])(
    'forbids every .env* variant, not only .env and .env.*: %s',
    (file) => {
      expect(findViolations([file], real)).toHaveLength(1);
    }
  );

  it('is satisfied by every file tracked in the repository', () => {
    expect(findViolations(trackedFiles(), real)).toEqual([]);
  });

  it('fails the command line check with exit code 1 for a branch that adds a local file', () => {
    // Build a throwaway repository: one clean commit, then a commit that adds a local file.
    const run = (cwd: string, ...args: string[]) =>
      spawnSync(
        'git',
        [
          '-c',
          'user.name=t',
          '-c',
          'user.email=t@example.com',
          '-c',
          'commit.gpgsign=false',
          // The platform null device is always empty, so a developer's global excludes cannot
          // make `git add` skip the file this test needs to commit.
          '-c',
          `core.excludesFile=${devNull}`,
          ...args,
        ],
        { cwd, encoding: 'utf8' }
      );
    const dir = mkdtempSync(join(tmpdir(), 'lfp-'));
    // An empty template: a git template can ship its own .git/info/exclude.
    run(dir, 'init', '-q', '--template=', '-b', 'main');
    writeFileSync(join(dir, 'a.txt'), 'x');
    run(dir, 'add', '.');
    run(dir, 'commit', '-q', '-m', 'base');
    writeFileSync(join(dir, 'x.local.json'), '{}');
    run(dir, 'add', '-f', '.');
    run(dir, 'commit', '-q', '-m', 'adds a local file');

    const bad = spawnSync(process.execPath, [SCRIPT, '--base', 'HEAD~1'], { cwd: dir, encoding: 'utf8' });
    expect(bad.status).toBe(1);
    expect(bad.stderr).toContain('x.local.json');

    const clean = spawnSync(process.execPath, [SCRIPT, '--base', 'HEAD'], { cwd: dir, encoding: 'utf8' });
    expect(clean.status).toBe(0);
    // Several git and node processes run here; a loaded machine can exceed vitest's 5 s default.
  }, 30_000);

  it('exits 2 with no mode, so a misconfigured workflow cannot pass silently', () => {
    expect(spawnSync(process.execPath, [SCRIPT], { encoding: 'utf8' }).status).toBe(2);
  });

  it('exits 2 when --head has no value', () => {
    expect(spawnSync(process.execPath, [SCRIPT, '--tracked', '--head'], { encoding: 'utf8' }).status).toBe(2);
  });
});

// The workflow runs this script from the trusted base branch against a pull request's commits,
// read as data with --head and never checked out.
describe('reading another commit with --head', () => {
  const git = (cwd: string, ...args: string[]) =>
    spawnSync(
      'git',
      [
        '-c',
        'user.name=t',
        '-c',
        'user.email=t@example.com',
        '-c',
        'commit.gpgsign=false',
        '-c',
        `core.excludesFile=${devNull}`,
        ...args,
      ],
      { cwd, encoding: 'utf8' }
    );
  const check = (cwd: string, ...args: string[]) =>
    spawnSync(process.execPath, [SCRIPT, ...args], { cwd, encoding: 'utf8' });

  // `main` is clean and checked out; branch `feature` carries two per-machine files, one with a
  // non-ASCII name (git quotes those unless asked not to, and a quoted name slips past patterns).
  const makeRepo = () => {
    const dir = mkdtempSync(join(tmpdir(), 'lfh-'));
    git(dir, 'init', '-q', '--template=', '-b', 'main');
    writeFileSync(join(dir, 'a.txt'), 'x');
    git(dir, 'add', '.');
    git(dir, 'commit', '-q', '-m', 'base');
    git(dir, 'checkout', '-q', '-b', 'feature');
    writeFileSync(join(dir, 'café.local.json'), '{}');
    writeFileSync(join(dir, '.envrc'), 'SECRET=1');
    git(dir, 'add', '-f', '.');
    git(dir, 'commit', '-q', '-m', 'carries per-machine files');
    git(dir, 'checkout', '-q', 'main');
    return dir;
  };

  it('flags the files in another commit even though a clean branch is checked out', () => {
    const dir = makeRepo();
    expect(check(dir, '--tracked').status).toBe(0);

    const result = check(dir, '--tracked', '--head', 'feature');
    expect(result.status).toBe(1);
    expect(result.stderr).toContain('.envrc');
    expect(result.stderr).toContain('café.local.json');
  }, 30_000);

  it('flags what a commit adds relative to a base', () => {
    const dir = makeRepo();
    expect(check(dir, '--base', 'main', '--head', 'feature').status).toBe(1);
    expect(check(dir, '--base', 'main', '--head', 'main').status).toBe(0);
  }, 30_000);

  it('leaves the working tree untouched', () => {
    const dir = makeRepo();
    check(dir, '--tracked', '--head', 'feature');
    expect(git(dir, 'status', '--porcelain').stdout).toBe('');
    expect(git(dir, 'rev-parse', '--abbrev-ref', 'HEAD').stdout.trim()).toBe('main');
  }, 30_000);

  it('exits 2 when the commit does not exist', () => {
    expect(check(makeRepo(), '--tracked', '--head', 'no-such-ref').status).toBe(2);
  }, 30_000);
});

describe('annotation', () => {
  const violation = (file: string) => ({ file, pattern: '**/*.local.*', reason: 'local' });

  it('is a plain error command for an ordinary file name', () => {
    expect(annotation(violation('docs/a.local.md'))).toBe(
      '::error file=docs/a.local.md::Local file must not be committed (**/*.local.*): local'
    );
  });

  it('encodes characters a pull request could use to end the command or start another', () => {
    const text = annotation(violation('a\n::error::forged,x:y%.local.json'));
    expect(text.split('\n')).toHaveLength(1);
    expect(text).toContain('file=a%0A%3A%3Aerror%3A%3Aforged%2Cx%3Ay%25.local.json::');
  });
});
