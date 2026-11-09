import { spawnSync } from 'node:child_process';
import { fileURLToPath } from 'node:url';
import { describe, expect, it } from 'vitest';
import { findViolations, loadPolicy, parsePolicy, trackedFiles, type Policy } from '../scripts/check-local-files.ts';

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

  it('is satisfied by every file tracked in the repository', () => {
    expect(findViolations(trackedFiles(), real)).toEqual([]);
  });

  it('fails the command line check with exit code 1 for a branch that adds a local file', () => {
    // Build a throwaway repository: one clean commit, then a commit that adds a local file.
    const run = (cwd: string, ...args: string[]) =>
      spawnSync('git', ['-c', 'user.name=t', '-c', 'user.email=t@example.com', '-c', 'commit.gpgsign=false', ...args], {
        cwd,
        encoding: 'utf8',
      });
    const dir = spawnSync(
      process.execPath,
      ['-e', "process.stdout.write(require('node:fs').mkdtempSync(require('node:os').tmpdir()+'/lfp-'))"],
      {
        encoding: 'utf8',
      }
    ).stdout;
    run(dir, 'init', '-q', '-b', 'main');
    spawnSync(process.execPath, ['-e', "require('node:fs').writeFileSync('a.txt','x')"], { cwd: dir });
    run(dir, 'add', '.');
    run(dir, 'commit', '-q', '-m', 'base');
    spawnSync(process.execPath, ['-e', "require('node:fs').writeFileSync('x.local.json','{}')"], { cwd: dir });
    run(dir, 'add', '.');
    run(dir, 'commit', '-q', '-m', 'adds a local file');

    const bad = spawnSync(process.execPath, [SCRIPT, '--base', 'HEAD~1'], { cwd: dir, encoding: 'utf8' });
    expect(bad.status).toBe(1);
    expect(bad.stderr).toContain('x.local.json');

    const clean = spawnSync(process.execPath, [SCRIPT, '--base', 'HEAD'], { cwd: dir, encoding: 'utf8' });
    expect(clean.status).toBe(0);
  });

  it('exits 2 with no mode, so a misconfigured workflow cannot pass silently', () => {
    expect(spawnSync(process.execPath, [SCRIPT], { encoding: 'utf8' }).status).toBe(2);
  });
});
