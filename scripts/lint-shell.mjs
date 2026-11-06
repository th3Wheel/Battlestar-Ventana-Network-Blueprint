import { spawnSync } from 'node:child_process';
import { readFile, readdir } from 'node:fs/promises';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

const repositoryRoot = path.resolve(path.dirname(fileURLToPath(import.meta.url)), '..');
const ignoredDirectories = new Set(['.git', 'node_modules', '.venv']);
const requiredVersion = (await readFile(path.join(repositoryRoot, '.shellcheck-version'), 'utf8')).trim();
const shellcheckImage = (await readFile(path.join(repositoryRoot, '.shellcheck-image'), 'utf8')).trim();
if (!new RegExp(`^koalaman/shellcheck:v${requiredVersion.replaceAll('.', '\\.')}@sha256:[a-f0-9]{64}$`)
  .test(shellcheckImage)) {
  throw new Error('.shellcheck-image must pin the version in .shellcheck-version and an immutable SHA-256 digest.');
}
const shellcheckEnvironment = Object.fromEntries(
  Object.entries(process.env).filter(([key]) => key.toUpperCase() !== 'SHELLCHECK_OPTS')
);

function runShellCheck(args, stdio) {
  const result = spawnSync('docker', [
    'run', '--rm',
    '--network=none',
    '--read-only',
    '--cap-drop=ALL',
    '--security-opt=no-new-privileges',
    '--mount', `type=bind,source=${repositoryRoot},target=/mnt,readonly`,
    '--workdir', '/mnt',
    '--env', 'SHELLCHECK_OPTS=',
    shellcheckImage,
    ...args,
  ], {
    cwd: repositoryRoot,
    env: shellcheckEnvironment,
    encoding: 'utf8',
    stdio,
    timeout: 300_000,
    maxBuffer: 1024 * 1024,
  });

  if (result.error?.code === 'ENOENT') {
    throw new Error('Docker is required for lint:shell but was not found on PATH. Start a Linux container engine.');
  }
  if (result.error) {
    throw result.error;
  }
  if (result.status === null) {
    throw new Error(`Docker ShellCheck terminated by signal ${result.signal ?? 'unknown'}.`);
  }
  return result;
}

async function findShellScripts(directory, scripts = []) {
  const entries = await readdir(directory, { withFileTypes: true });

  for (const entry of entries) {
    const entryPath = path.join(directory, entry.name);

    if (entry.isDirectory()) {
      if (!ignoredDirectories.has(entry.name) && !entry.name.startsWith('.venv')) {
        await findShellScripts(entryPath, scripts);
      }
    } else if (entry.isFile() && entry.name.endsWith('.sh')) {
      scripts.push(path.relative(repositoryRoot, entryPath).split(path.sep).join('/'));
    }
  }

  return scripts;
}

const shellScripts = (await findShellScripts(repositoryRoot)).sort();

if (shellScripts.length === 0) {
  // eslint-disable-next-line no-console -- command-line output
  console.log('No shell scripts found.');
} else {
  const versionResult = runShellCheck(['--version'], 'pipe');
  if (versionResult.status !== 0) {
    throw new Error(
      'Docker could not start ShellCheck. Ensure a Linux container engine is running and the pinned image is available. ' +
      `${versionResult.stderr?.trim() ?? ''}`
    );
  }
  const installedVersion = /^version:\s*(\S+)/m.exec(versionResult.stdout)?.[1];

  if (installedVersion !== requiredVersion) {
    throw new Error(
      `Expected ShellCheck ${requiredVersion}; found ${installedVersion ?? 'an unreadable version'}. ` +
      'Check the image pinned in .shellcheck-image.'
    );
  }

  const result = runShellCheck([
    '--rcfile', '/mnt/.shellcheckrc',
    '--severity=style',
    '--format=gcc',
    '--',
    ...shellScripts,
  ], 'inherit');
  process.exitCode = result.status;
}
