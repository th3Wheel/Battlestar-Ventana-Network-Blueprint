import { readFile, readdir, writeFile } from 'node:fs/promises';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);
const repoRoot = path.resolve(__dirname, '..');

const sourceFile = path.join(repoRoot, 'mcp-config.json');
const targets = [
  { file: '.mcp.json', rootKey: 'mcpServers' },
  { file: '.cursor/mcp.json', rootKey: 'mcpServers' },
  { file: '.vscode/mcp.json', rootKey: 'servers' },
  { file: '.gemini/settings.json', rootKey: 'mcpServers' },
];

const guardOnly = process.argv.includes('--guard');
const checkOnly = process.argv.includes('--check') || guardOnly;

const allowedConfigFiles = new Map([
  ['mcp-config.json', 'mcpServers'],
  ['.mcp.json', 'mcpServers'],
  ['.cursor/mcp.json', 'mcpServers'],
  ['.vscode/mcp.json', 'servers'],
  ['.gemini/settings.json', 'mcpServers'],
  ['infrastructure/xpipe/mcp-config.example.json', 'mcpServers'],
]);

function stripJsonComments(input) {
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

function parseJsonFlexible(text, filePath) {
  try {
    return JSON.parse(text);
  } catch {
    try {
      return JSON.parse(stripJsonComments(text));
    } catch (error) {
      throw new Error(`Failed to parse JSON from ${filePath}: ${error.message}`);
    }
  }
}

function getServersObject(config, rootKey) {
  if (config && typeof config[rootKey] === 'object' && config[rootKey] !== null) {
    return config[rootKey];
  }

  if (rootKey === 'mcpServers' && config && typeof config.servers === 'object' && config.servers !== null) {
    return config.servers;
  }

  if (rootKey === 'servers' && config && typeof config.mcpServers === 'object' && config.mcpServers !== null) {
    return config.mcpServers;
  }

  return {};
}

function looksLikeServerMap(value) {
  if (!value || typeof value !== 'object' || Array.isArray(value)) {
    return false;
  }

  return Object.values(value).some((entry) => {
    if (!entry || typeof entry !== 'object' || Array.isArray(entry)) {
      return false;
    }

    return ['command', 'url', 'type', 'args', 'env', 'headers', 'tools'].some((key) => key in entry);
  });
}

async function walkRepo(directory, collected = []) {
  const entries = await readdir(directory, { withFileTypes: true });

  for (const entry of entries) {
    const absolutePath = path.join(directory, entry.name);

    if (entry.isDirectory()) {
      if (entry.name === '.git' || entry.name === 'node_modules') {
        continue;
      }

      await walkRepo(absolutePath, collected);
      continue;
    }

    collected.push(absolutePath);
  }

  return collected;
}

async function discoverMcpConfigs() {
  const files = await walkRepo(repoRoot);
  const discovered = [];

  for (const absolutePath of files) {
    const relativePath = path.relative(repoRoot, absolutePath).replaceAll('\\', '/');
    const filename = path.basename(relativePath);

    if (!['.json', '.jsonc'].includes(path.extname(filename).toLowerCase())) {
      continue;
    }

    let parsed;
    try {
      parsed = parseJsonFlexible(await readFile(absolutePath, 'utf8'), relativePath);
    } catch {
      continue;
    }

    if (parsed && typeof parsed !== 'object') {
      continue;
    }

    const rootCandidates = [
      ['mcpServers', parsed?.mcpServers],
      ['servers', parsed?.servers],
      ['mcp.servers', parsed?.['mcp.servers']],
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

function getExpectedFiles() {
  return new Set(allowedConfigFiles.keys());
}

function formatUnexpectedFiles(unexpectedFiles) {
  return unexpectedFiles.map((file) => `- ${file}`).join('\n');
}

function buildMergedServers(sharedServers, existingServers) {
  const managedServerNames = new Set(Object.keys(sharedServers));
  const unmanagedEntries = Object.entries(existingServers).filter(([name]) => !managedServerNames.has(name));
  return {
    ...sharedServers,
    ...Object.fromEntries(unmanagedEntries),
  };
}

async function fileExists(filePath) {
  try {
    await readFile(filePath, 'utf8');
    return true;
  } catch {
    return false;
  }
}

async function main() {
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

  const missingConfigs = [...expectedFiles].filter((file) => !discoveredConfigs.some((candidate) => candidate.file === file));

  const changes = [];

  for (const target of targets) {
    const targetPath = path.join(repoRoot, target.file);
    const exists = await fileExists(targetPath);
    const currentConfig = exists
      ? parseJsonFlexible(await readFile(targetPath, 'utf8'), target.file)
      : {};

    const existingServers = getServersObject(currentConfig, target.rootKey);
    const mergedServers = buildMergedServers(sharedServers, existingServers);

    const nextConfig = {
      ...currentConfig,
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

  const guardFailures = [];

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
      console.log('MCP configs already synchronized.');
      return;
    }

    if (changes.length > 0) {
      console.log('MCP configs out of sync:');
      for (const file of changes) {
        console.log(`- ${file}`);
      }
    }

    if (guardFailures.length > 0) {
      console.error(guardFailures.join('\n'));
    }

    process.exit(1);
  }

  if (guardFailures.length > 0) {
    console.error(guardFailures.join('\n'));
    process.exit(1);
  }

  if (changes.length === 0) {
    console.log('MCP configs already synchronized.');
    return;
  }

  console.log('Synchronized MCP configs:');
  for (const file of changes) {
    console.log(`- ${file}`);
  }
}

main().catch((error) => {
  console.error(error.message);
  process.exit(1);
});
