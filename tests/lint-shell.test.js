import { afterEach, describe, expect, it, vi } from 'vitest';
import { readFileSync } from 'node:fs';

const { spawnSync, readFile, readdir } = vi.hoisted(() => ({
  spawnSync: vi.fn(),
  readFile: vi.fn(),
  readdir: vi.fn(),
}));

vi.mock('node:child_process', () => ({ spawnSync }));
vi.mock('node:fs/promises', () => ({ readFile, readdir }));

const originalExitCode = process.exitCode;
const image = 'koalaman/shellcheck:v0.11.0@sha256:61862eba1fcf09a484ebcc6feea46f1782532571a34ed51fedf90dd25f925a8d';

afterEach(() => {
  process.exitCode = originalExitCode;
  vi.unstubAllEnvs();
  vi.resetAllMocks();
  vi.resetModules();
});

function setup() {
  readFile.mockImplementation(async (filename) => filename.endsWith('.shellcheck-image') ? `${image}\n` : '0.11.0\n');
  readdir.mockResolvedValue([
    { name: 'example.sh', isDirectory: () => false, isFile: () => true },
  ]);
}

describe('ShellCheck invocation', () => {
  it('keeps the mounted configuration LF-only and enforces LF on checkout', () => {
    const config = readFileSync(new URL('../.shellcheckrc', import.meta.url), 'utf8');
    const attributes = readFileSync(new URL('../.gitattributes', import.meta.url), 'utf8');

    expect(config).not.toContain('\r');
    expect(config.endsWith('\n')).toBe(true);
    expect(attributes.split(/\r?\n/)).toContain('/.shellcheckrc text eol=lf');
  });

  it('enforces project configuration and strips ambient options', async () => {
    setup();
    vi.stubEnv('SHELLCHECK_OPTS', '--exclude=SC2086');
    spawnSync.mockReturnValueOnce({ status: 0, stdout: 'version: 0.11.0\n' });
    spawnSync.mockReturnValueOnce({ status: 1 });

    await import('../scripts/lint-shell.mjs');

    const [command, args, options] = spawnSync.mock.calls[1];
    expect(command).toBe('docker');
    expect(args).toEqual([
      'run', '--rm',
      '--network=none', '--read-only', '--cap-drop=ALL',
      '--security-opt=no-new-privileges',
      '--mount', `type=bind,source=${options.cwd},target=/mnt,readonly`,
      '--workdir', '/mnt', '--env', 'SHELLCHECK_OPTS=', image,
      '--rcfile', '/mnt/.shellcheckrc',
      '--severity=style', '--format=gcc', '--', 'example.sh',
    ]);
    for (const [, , invocationOptions] of spawnSync.mock.calls) {
      expect(Object.keys(invocationOptions.env).map((key) => key.toUpperCase()))
        .not.toContain('SHELLCHECK_OPTS');
    }
    expect(process.exitCode).toBe(1);
  });

  it('rejects a different version without linting', async () => {
    setup();
    spawnSync.mockReturnValueOnce({ status: 0, stdout: 'version: 0.10.0\n' });

    await expect(import('../scripts/lint-shell.mjs')).rejects.toThrow('Expected ShellCheck 0.11.0');
    expect(spawnSync).toHaveBeenCalledTimes(1);
  });

  it('reports a missing executable', async () => {
    setup();
    spawnSync.mockReturnValueOnce({ error: { code: 'ENOENT' } });

    await expect(import('../scripts/lint-shell.mjs')).rejects.toThrow('was not found on PATH');
  });

  it('reports container startup failures without linting', async () => {
    setup();
    spawnSync.mockReturnValueOnce({ status: 125, stderr: 'Cannot connect to the Docker daemon' });

    await expect(import('../scripts/lint-shell.mjs')).rejects.toThrow('Cannot connect to the Docker daemon');
    expect(spawnSync).toHaveBeenCalledTimes(1);
  });

  it('rejects an unpinned image', async () => {
    setup();
    readFile.mockImplementation(async (filename) => filename.endsWith('.shellcheck-image')
      ? 'koalaman/shellcheck:stable\n'
      : '0.11.0\n');

    await expect(import('../scripts/lint-shell.mjs')).rejects.toThrow('immutable SHA-256 digest');
    expect(spawnSync).not.toHaveBeenCalled();
  });

  it('passes sorted container paths and skips dependency directories', async () => {
    setup();
    readdir.mockResolvedValueOnce([
      { name: 'scripts', isDirectory: () => true },
      { name: '.venv', isDirectory: () => true },
      { name: '.venv_3.18', isDirectory: () => true },
      { name: 'node_modules', isDirectory: () => true },
      { name: '.git', isDirectory: () => true },
      { name: 'a.sh', isDirectory: () => false, isFile: () => true },
    ]).mockResolvedValueOnce([
      { name: 'z.sh', isDirectory: () => false, isFile: () => true },
    ]);
    spawnSync.mockReturnValueOnce({ status: 0, stdout: 'version: 0.11.0\n' });
    spawnSync.mockReturnValueOnce({ status: 0 });

    await import('../scripts/lint-shell.mjs');

    expect(spawnSync.mock.calls[1][1].slice(-2)).toEqual(['a.sh', 'scripts/z.sh']);
    expect(readdir).toHaveBeenCalledTimes(2);
  });

  it('does not require Docker when no shell scripts exist', async () => {
    setup();
    readdir.mockResolvedValue([]);
    const log = vi.spyOn(console, 'log').mockImplementation(() => {});

    try {
      await import('../scripts/lint-shell.mjs');
      expect(spawnSync).not.toHaveBeenCalled();
      expect(log).toHaveBeenCalledWith('No shell scripts found.');
    } finally {
      log.mockRestore();
    }
  });
});
