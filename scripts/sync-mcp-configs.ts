import { execFile } from 'node:child_process';
import { readFile, readdir, writeFile } from 'node:fs/promises';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

type RootKey = 'mcpServers' | 'servers' | 'mcp.servers';
type TargetRootKey = Exclude<RootKey, 'mcp.servers'>;
type ConfigRecord = Record<string, unknown>;
type ServerMap = Record<string, unknown>;

interface Target {
  file: string;
  rootKey: TargetRootKey;
}

interface DiscoveredConfig {
  file: string;
  rootKey: RootKey;
}

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);
const repoRoot = path.resolve(__dirname, '..');

const sourceFile = path.join(repoRoot, 'mcp-config.json');
const targets: Target[] = [
  { file: '.mcp.json', rootKey: 'mcpServers' },
  { file: '.cursor/mcp.json', rootKey: 'mcpServers' },
  { file: '.vscode/mcp.json', rootKey: 'servers' },
  { file: '.gemini/settings.json', rootKey: 'mcpServers' },
];

const guardOnly = process.argv.includes('--guard');
const checkOnly = process.argv.includes('--check') || guardOnly;

const allowedConfigFiles = new Map<string, RootKey>([
  ['mcp-config.json', 'mcpServers'],
  ['.mcp.json', 'mcpServers'],
  ['.cursor/mcp.json', 'mcpServers'],
  ['.vscode/mcp.json', 'servers'],
  ['.gemini/settings.json', 'mcpServers'],
  ['infrastructure/xpipe/mcp-config.example.json', 'mcpServers'],
]);

async function getIgnoredPaths(paths: string[]): Promise<Set<string>> {
  if (paths.length === 0) {
    return new Set();
  }

  const result = await new Promise<string>((resolve, reject) => {
    const child = execFile(
      'git',
      ['check-ignore', '--no-index', '--stdin', '-z'],
      { cwd: repoRoot, encoding: 'utf8' },
      (error, stdout, stderr) => {
        if (error && error.code !== 1) {
          reject(new Error(`git check-ignore failed: ${stderr || error.message}`, { cause: error }));
          return;
        }

        resolve(stdout);
      }
    );

    child.stdin?.end(paths.join('\0') + '\0');
  });

  return new Set(result.split('\0').filter(Boolean).map((ignoredPath) => ignoredPath.replace(/\/$/, '')));
}

function stripJsonComments(input: string): string {
  let output = '';
  let inString = false;
  let inLineComment = false;
  let inBlockComment = false;
  let escaped = false;

  for (let i = 0; i < input.length; i += 1) {
    const ch = input[i];
    const next = input[i + 1];

    if (inLineComment) {
      if (ch === '\n') {
        inLineComment = false;
        output += ch;
      }
      continue;
    }

    if (inBlockComment) {
      if (ch === '*' && next === '/') {
        inBlockComment = false;
        i += 1;
      }
      continue;
    }

    if (inString) {
      output += ch;
      if (escaped) {
        escaped = false;
      } else if (ch === '\\') {
        escaped = true;
      } else if (ch === '"') {
        inString = false;
      }
      continue;
    }

    if (ch === '"') {
      inString = true;
      output += ch;
      continue;
    }

    if (ch === '/' && next === '/') {
      inLineComment = true;
      i += 1;
      continue;
    }

    if (ch === '/' && next === '*') {
      inBlockComment = true;
      i += 1;
      continue;
    }

    output += ch;
  }

  return output;
}

function parseJsonFlexible(text: string, filePath: string): unknown {
  try {
    return JSON.parse(text);
  } catch {
    try {
      return JSON.parse(stripJsonComments(text));
    } catch (error: unknown) {
      const message = error instanceof Error ? error.message : String(error);
      throw new Error(`Failed to parse JSON from ${filePath}: ${message}`, { cause: error });
    }
  }
}

function isNonNullObject(value: unknown): value is object {
  return typeof value === 'object' && value !== null;
}

function getProperty(value: unknown, key: string): unknown {
  if (!isNonNullObject(value)) {
    return undefined;
  }

  return (value as ConfigRecord)[key];
}

function getServersObject(config: unknown, rootKey: TargetRootKey): ServerMap {
  const rootValue = getProperty(config, rootKey);
  if (isNonNullObject(rootValue)) {
    return rootValue as ServerMap;
  }

  const alternateRootKey: TargetRootKey = rootKey === 'mcpServers' ? 'servers' : 'mcpServers';
  const alternateValue = getProperty(config, alternateRootKey);
  if (isNonNullObject(alternateValue)) {
    return alternateValue as ServerMap;
  }

  return {};
}

function looksLikeServerMap(value: unknown): value is ServerMap {
  if (!isNonNullObject(value) || Array.isArray(value)) {
    return false;
  }

  return Object.values(value).some((entry: unknown) => {
    if (!isNonNullObject(entry) || Array.isArray(entry)) {
      return false;
    }

    return ['command', 'url', 'type', 'args', 'env', 'headers', 'tools'].some((key) => key in entry);
  });
}

async function walkRepo(directory: string, collected: string[] = []): Promise<string[]> {
  const entries = await readdir(directory, { withFileTypes: true });
  const relativePaths = entries.map((entry) =>
    path.relative(repoRoot, path.join(directory, entry.name)).replaceAll('\\', '/')
  );
  const ignoredPaths = await getIgnoredPaths(
    entries.map((entry, index) => (entry.isDirectory() ? `${relativePaths[index]}/` : relativePaths[index]))
  );

  for (const [index, entry] of entries.entries()) {
    if (ignoredPaths.has(relativePaths[index])) {
      continue;
    }

    const absolutePath = path.join(directory, entry.name);

    if (entry.isDirectory()) {
      if (entry.name === '.git') {
        continue;
      }

      await walkRepo(absolutePath, collected);
      continue;
    }

    collected.push(absolutePath);
  }

  return collected;
}

async function discoverMcpConfigs(): Promise<DiscoveredConfig[]> {
  const files = await walkRepo(repoRoot);
  const discovered: DiscoveredConfig[] = [];

  for (const absolutePath of files) {
    const relativePath = path.relative(repoRoot, absolutePath).replaceAll('\\', '/');
    const filename = path.basename(relativePath);

    if (!['.json', '.jsonc'].includes(path.extname(filename).toLowerCase())) {
      continue;
    }

    let parsed: unknown;
    try {
      parsed = parseJsonFlexible(await readFile(absolutePath, 'utf8'), relativePath);
    } catch {
      continue;
    }

    if (parsed && typeof parsed !== 'object') {
      continue;
    }

    const rootCandidates: [RootKey, unknown][] = [
      ['mcpServers', getProperty(parsed, 'mcpServers')],
      ['servers', getProperty(parsed, 'servers')],
      ['mcp.servers', getProperty(parsed, 'mcp.servers')],
    ];

    for (const [rootKey, value] of rootCandidates) {
      if (looksLikeServerMap(value)) {
        discovered.push({ file: relativePath, rootKey });
        break;
      }
    }
  }

  return discovered;
}

function getExpectedFiles(): Set<string> {
  return new Set(allowedConfigFiles.keys());
}

function formatUnexpectedFiles(unexpectedFiles: string[]): string {
  return unexpectedFiles.map((file) => `- ${file}`).join('\n');
}

function buildMergedServers(sharedServers: ServerMap, existingServers: ServerMap): ServerMap {
  const managedServerNames = new Set(Object.keys(sharedServers));
  const unmanagedEntries = Object.entries(existingServers).filter(([name]) => !managedServerNames.has(name));
  return {
    ...sharedServers,
    ...Object.fromEntries(unmanagedEntries),
  };
}

async function fileExists(filePath: string): Promise<boolean> {
  try {
    await readFile(filePath, 'utf8');
    return true;
  } catch {
    return false;
  }
}

async function main(): Promise<void> {
  const sourceText = await readFile(sourceFile, 'utf8');
  const sourceConfig = parseJsonFlexible(sourceText, sourceFile);
  const sharedServers = getServersObject(sourceConfig, 'mcpServers');

  if (Object.keys(sharedServers).length === 0) {
    throw new Error('mcp-config.json does not contain a non-empty mcpServers object.');
  }

  const discoveredConfigs = await discoverMcpConfigs();
  const expectedFiles = getExpectedFiles();
  const unexpectedConfigs = discoveredConfigs
    .filter(({ file }) => !expectedFiles.has(file))
    .map(({ file, rootKey }) => `${file} (${rootKey})`)
    .sort();

  const missingConfigs = [...expectedFiles].filter(
    (file) => !discoveredConfigs.some((candidate) => candidate.file === file)
  );

  const changes: string[] = [];

  for (const target of targets) {
    const targetPath = path.join(repoRoot, target.file);
    const exists = await fileExists(targetPath);
    const currentConfig = exists ? parseJsonFlexible(await readFile(targetPath, 'utf8'), target.file) : {};

    const existingServers = getServersObject(currentConfig, target.rootKey);
    const mergedServers = buildMergedServers(sharedServers, existingServers);

    const nextConfig: ConfigRecord = {
      ...(currentConfig as ConfigRecord),
      [target.rootKey]: mergedServers,
    };

    const formatted = `${JSON.stringify(nextConfig, null, 2)}\n`;
    const currentText = exists ? await readFile(targetPath, 'utf8') : '';

    if (formatted !== currentText) {
      changes.push(target.file);
      if (!checkOnly) {
        await writeFile(targetPath, formatted, 'utf8');
      }
    }
  }

  const guardFailures: string[] = [];

  if (unexpectedConfigs.length > 0) {
    guardFailures.push('Unexpected MCP config files found:');
    guardFailures.push(formatUnexpectedFiles(unexpectedConfigs));
  }

  if (missingConfigs.length > 0) {
    guardFailures.push('Expected MCP config files missing:');
    guardFailures.push(formatUnexpectedFiles(missingConfigs));
  }

  if (checkOnly) {
    if (changes.length === 0 && guardFailures.length === 0) {
      process.stdout.write('MCP configs already synchronized.\n');
      return;
    }

    if (changes.length > 0) {
      process.stdout.write('MCP configs out of sync:\n');
      for (const file of changes) {
        process.stdout.write(`- ${file}\n`);
      }
    }

    if (guardFailures.length > 0) {
      process.stderr.write(guardFailures.join('\n') + '\n');
    }

    process.exit(1);
  }

  if (guardFailures.length > 0) {
    process.stderr.write(guardFailures.join('\n') + '\n');
    process.exit(1);
  }

  if (changes.length === 0) {
    process.stdout.write('MCP configs already synchronized.\n');
    return;
  }

  process.stdout.write('Synchronized MCP configs:\n');
  for (const file of changes) {
    process.stdout.write(`- ${file}\n`);
  }
}

main().catch((error: unknown) => {
  const message = error instanceof Error ? error.message : String(error);
  process.stderr.write(message + '\n');
  process.exit(1);
});
