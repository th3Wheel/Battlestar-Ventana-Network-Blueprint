// PreToolUse hook: refuses agent-driven merges into the default branch that touch the paths
// AGENTS.md lists under "Never merges without a human". A person merges those themselves.
// Merges into other branches (an integration branch, say) are not gated; the PR that carries
// such a branch into the default branch is.
//
// This is a guardrail for cooperative agents, not a security boundary: it reads
// shell text, which cannot be parsed completely. The rule that keeps it honest is
// "deny what you cannot resolve": a command that looks like a merge but whose
// target, destination or diff cannot be determined is refused, never allowed.
import { spawnSync } from 'node:child_process';
import { realpathSync } from 'node:fs';
import { resolve } from 'node:path';
import { fileURLToPath } from 'node:url';

const RISK_PREFIXES = ['config/', 'ansible/', 'infrastructure/'];
const RISK_FILES = new Set([
  'mcp-config.json',
  '.mcp.json',
  '.cursor/mcp.json',
  '.vscode/mcp.json',
  '.gemini/settings.json',
]);
const DEFAULT_BRANCHES = new Set(['master', 'main']);
// Hosts give a hook 30 seconds and some fail open on timeout, so stay well under it.
const DEADLINE_MS = 20_000;

// Flags that take a separate value, so the value is not mistaken for a positional argument.
const GH_VALUE_FLAGS = new Set([
  '-R',
  '--repo',
  '-t',
  '--subject',
  '-b',
  '--body',
  '-F',
  '--body-file',
  '-A',
  '--author-email',
  '--match-head-commit',
  '-X',
  '--method',
  '-f',
  '--raw-field',
  '--field',
  '-H',
  '--header',
  '-q',
  '--jq',
  '--template',
  '--input',
  '--cache',
  '--hostname',
  '-p',
  '--preview',
]);
const GIT_VALUE_FLAGS = new Set(['-c', '--git-dir', '--work-tree', '--namespace', '--config-env', '--super-prefix']);
const PUSH_VALUE_FLAGS = new Set(['-o', '--push-option', '--receive-pack', '--exec', '--repo']);
const WRAPPERS = new Set(['env', 'sudo', 'command', 'exec', 'time', 'nohup', 'nice']);
const SHELLS = new Set(['bash', 'sh', 'zsh', 'dash', 'pwsh', 'powershell', 'cmd']);

export function isRiskPath(file: string): boolean {
  const path = file
    .replaceAll('\\', '/')
    .replace(/^\.?\//, '')
    .toLowerCase();
  return RISK_FILES.has(path) || RISK_PREFIXES.some((prefix) => path.startsWith(prefix));
}

type Word = { text: string; dynamic: boolean };

export type Located =
  | { kind: 'pr'; selector?: string; repo?: string }
  | { kind: 'push'; remote: string; source: string; branch: string; cwd?: string };
export type Merge = Located | { kind: 'deny'; reason: string };

export type Runner = (cmd: string, args: string[]) => string;

class Unresolvable extends Error {}

const messageOf = (error: unknown): string => (error instanceof Error ? error.message : String(error));

// Runs a subprocess, bounded by one deadline shared by every lookup for this event.
export function makeRunner(timeoutMs = DEADLINE_MS): Runner {
  const deadline = Date.now() + timeoutMs;
  return (cmd, args) => {
    const remaining = deadline - Date.now();
    if (remaining <= 0) {
      throw new Error('lookup deadline exceeded');
    }
    const result = spawnSync(cmd, args, {
      encoding: 'utf8',
      timeout: remaining,
      maxBuffer: 64 * 1024 * 1024,
      windowsHide: true,
    });
    if (result.error) {
      throw new Error(result.error.message);
    }
    if (result.status !== 0) {
      throw new Error((result.stderr || `${cmd} exited with ${result.status}`).trim());
    }
    return result.stdout;
  };
}

// Splits shell text into simple commands of words, honouring quotes. Parentheses and
// backticks separate commands so `echo $(gh pr merge 1)` still exposes the inner merge.
// A word is "dynamic" when it contains an expansion ($ or a backtick) outside single quotes.
export function splitCommands(command: string): Word[][] {
  const commands: Word[][] = [];
  let words: Word[] = [];
  let text = '';
  let dynamic = false;
  let inWord = false;
  const endWord = () => {
    if (inWord) {
      words.push({ text, dynamic });
    }
    text = '';
    dynamic = false;
    inWord = false;
  };
  const endCommand = () => {
    endWord();
    if (words.length > 0) {
      commands.push(words);
    }
    words = [];
  };

  for (let i = 0; i < command.length; i++) {
    const ch = command[i];
    if (ch === "'") {
      inWord = true;
      const end = command.indexOf("'", i + 1);
      const stop = end < 0 ? command.length : end;
      text += command.slice(i + 1, stop);
      i = stop;
    } else if (ch === '"') {
      inWord = true;
      for (i++; i < command.length && command[i] !== '"'; i++) {
        const c = command[i];
        const next = command[i + 1];
        if (c === '\\' && next !== undefined && '"\\$`'.includes(next)) {
          text += next;
          i++;
        } else {
          if (c === '$' || c === '`') {
            dynamic = true;
          }
          text += c;
        }
      }
    } else if (ch === '\\' && i + 1 < command.length) {
      inWord = true;
      text += command[++i];
    } else if (ch === '\n' || ';&|()`'.includes(ch)) {
      if (ch === '`') {
        dynamic = true;
      }
      endCommand();
    } else if (/\s/.test(ch)) {
      endWord();
    } else {
      if (ch === '$') {
        dynamic = true;
      }
      inWord = true;
      text += ch;
    }
  }
  endCommand();
  return commands;
}

const baseName = (word: string): string => (word.split(/[\\/]/).pop() ?? word).replace(/\.exe$/i, '').toLowerCase();
const deny = (reason: string): Merge => ({ kind: 'deny', reason });
const at = (cwd?: string): string[] => (cwd ? ['-C', cwd] : []);

type GhArgs = { positionals: Word[]; flags: { name: string; value?: Word }[] };

function parseGh(words: Word[]): GhArgs {
  const positionals: Word[] = [];
  const flags: GhArgs['flags'] = [];
  for (let i = 1; i < words.length; i++) {
    const word = words[i];
    const equals = word.text.match(/^(--?[\w-]+)=([\s\S]*)$/);
    if (equals) {
      flags.push({ name: equals[1], value: { text: equals[2], dynamic: word.dynamic } });
    } else if (GH_VALUE_FLAGS.has(word.text)) {
      flags.push({ name: word.text, value: words[++i] });
    } else if (word.text.startsWith('-') && word.text.length > 1) {
      flags.push({ name: word.text });
    } else {
      positionals.push(word);
    }
  }
  return { positionals, flags };
}

function analyzeGh(words: Word[], merges: Merge[]): void {
  const { positionals, flags } = parseGh(words);
  const flag = (...names: string[]) => flags.find((f) => names.includes(f.name));
  const [group, action, selector] = positionals;

  if (group?.text === 'pr' && action?.text === 'merge') {
    if (flag('--disable-auto')) {
      return;
    }
    if (flag('--auto')) {
      merges.push(
        deny(
          '`gh pr merge --auto` merges later, after this check, so the diff cannot be vouched for. Wait for checks, then merge immediately.'
        )
      );
      return;
    }
    const repo = flag('-R', '--repo')?.value;
    if (selector?.dynamic || repo?.dynamic) {
      merges.push(
        deny('the PR or repository is a shell variable, so the diff cannot be inspected. Pass a literal PR number.')
      );
      return;
    }
    merges.push({ kind: 'pr', selector: selector?.text, repo: repo?.text });
    return;
  }

  if (group?.text === 'api') {
    const everything = words.map((w) => w.text).join(' ');
    if (/mergePullRequest|enablePullRequestAutoMerge/i.test(everything)) {
      merges.push(deny('a GraphQL merge mutation cannot be inspected.'));
      return;
    }
    const endpoint = action;
    if (!endpoint) {
      return;
    }
    if (/git\/refs\/heads\/(master|main)\b/i.test(endpoint.text)) {
      merges.push(deny('moving the default branch ref through the API cannot be inspected.'));
      return;
    }
    if (/(^|\/)merge(\?.*)?$/.test(endpoint.text) || /auto[_-]?merge/i.test(endpoint.text)) {
      const match = endpoint.text.match(/repos\/([^/]+)\/([^/]+)\/pulls\/(\d+)\/merge$/);
      if (endpoint.dynamic || !match) {
        merges.push(deny('the merge endpoint has an unresolved repository or PR number. Use literal values.'));
        return;
      }
      const repo = match[1].includes('{') || match[2].includes('{') ? undefined : `${match[1]}/${match[2]}`;
      merges.push({ kind: 'pr', repo, selector: match[3] });
    }
  }
}

function analyzePush(rest: Word[], cwd: string | undefined, run: Runner, merges: Merge[]): void {
  const positionals: Word[] = [];
  let deleting = false;
  for (let i = 0; i < rest.length; i++) {
    const text = rest[i].text;
    if (text === '--all' || text === '--mirror') {
      merges.push(
        deny(`\`git push ${text}\` can update the default branch and cannot be inspected. Push named branches.`)
      );
      return;
    }
    if (text === '-d' || text === '--delete') {
      deleting = true;
    } else if (PUSH_VALUE_FLAGS.has(text)) {
      i++;
    } else if (text.startsWith('-')) {
      continue;
    } else {
      positionals.push(rest[i]);
    }
  }
  if (positionals.some((w) => w.dynamic)) {
    merges.push(deny('the push remote or branch is a shell variable, so the destination cannot be determined.'));
    return;
  }

  const git = (args: string[]) => run('git', [...at(cwd), ...args]).trim();
  const config = (key: string): string => {
    try {
      return git(['config', '--get', key]);
    } catch {
      return '';
    }
  };
  const currentBranch = (): string => {
    try {
      return git(['symbolic-ref', '--short', '-q', 'HEAD']);
    } catch {
      throw new Unresolvable(
        'HEAD is detached, so the push destination cannot be determined. Name it, e.g. `git push origin my-branch`.'
      );
    }
  };
  const remoteFor = (branch: string): string =>
    config(`branch.${branch}.pushRemote`) ||
    config('remote.pushDefault') ||
    config(`branch.${branch}.remote`) ||
    'origin';

  try {
    const explicitRemote = positionals[0]?.text;
    const specs = positionals.slice(1).map((w) => w.text);

    if (specs.length === 0) {
      const branch = currentBranch();
      const mode = config('push.default') || 'simple';
      if (mode === 'matching' || mode === 'nothing') {
        merges.push(deny(`push.default=${mode} makes the destination of a bare push unclear. Name the branch.`));
        return;
      }
      let destination = branch;
      if (mode === 'upstream' || mode === 'tracking') {
        destination = config(`branch.${branch}.merge`).replace(/^refs\/heads\//, '');
        if (!destination) {
          throw new Unresolvable(`${branch} has no upstream, so the destination cannot be determined.`);
        }
      }
      if (DEFAULT_BRANCHES.has(destination)) {
        merges.push({
          kind: 'push',
          remote: explicitRemote ?? remoteFor(branch),
          source: branch,
          branch: destination,
          cwd,
        });
      }
      return;
    }

    for (const spec of specs) {
      const refspec = spec.replace(/^\+/, '');
      if (refspec.includes('*')) {
        merges.push(deny('a wildcard refspec cannot be inspected. Name the branch.'));
        return;
      }
      const colon = refspec.indexOf(':');
      let source = colon < 0 ? refspec : refspec.slice(0, colon);
      let target = colon < 0 ? refspec : refspec.slice(colon + 1);
      if (deleting) {
        source = '';
        target = refspec;
      }
      if (target === 'HEAD') {
        target = currentBranch();
      }
      target = target.replace(/^refs\/heads\//, '');
      if (target.startsWith('refs/') || !DEFAULT_BRANCHES.has(target)) {
        continue;
      }
      if (source === '') {
        merges.push(deny(`deleting ${target} is not something an agent does.`));
        return;
      }
      merges.push({ kind: 'push', remote: explicitRemote ?? 'origin', source, branch: target, cwd });
    }
  } catch (error) {
    merges.push(
      deny(
        error instanceof Unresolvable ? error.message : `could not resolve the push destination (${messageOf(error)}).`
      )
    );
  }
}

function analyze(words: Word[], run: Runner, merges: Merge[], depth = 0): void {
  let start = 0;
  while (start < words.length) {
    const text = words[start].text;
    if (/^[A-Za-z_][A-Za-z0-9_]*=/.test(text)) {
      start++;
    } else if (WRAPPERS.has(baseName(text))) {
      start++;
      while (words[start]?.text.startsWith('-')) {
        start++;
      }
    } else {
      break;
    }
  }
  const command = words.slice(start);
  if (command.length === 0) {
    return;
  }
  if (depth > 4) {
    merges.push(deny('commands are nested too deeply to inspect.'));
    return;
  }
  const name = baseName(command[0].text);

  if (command[0].dynamic && command.some((w) => /^(merge|push)$/.test(w.text))) {
    merges.push(deny('the command itself is a shell variable, so a merge or push cannot be ruled out.'));
    return;
  }

  if (SHELLS.has(name) || name === 'eval') {
    const index = name === 'eval' ? 0 : command.findIndex((w, i) => i > 0 && /^(-[a-z]*c|-command|\/c)$/i.test(w.text));
    if (command.some((w) => /^-(e|enc|encodedcommand)$/i.test(w.text))) {
      merges.push(deny('an encoded command cannot be inspected.'));
      return;
    }
    if (index >= 0) {
      const script = command
        .slice(index + 1)
        .map((w) => w.text)
        .join(' ');
      for (const inner of splitCommands(script)) {
        analyze(inner, run, merges, depth + 1);
      }
    }
    return;
  }

  if (name === 'gh') {
    analyzeGh(command, merges);
  } else if (name === 'git') {
    let cwd: string | undefined;
    let i = 1;
    for (; i < command.length; i++) {
      const text = command[i].text;
      if (text === '-C') {
        const value = command[++i];
        if (!value) {
          break;
        }
        if (value.dynamic) {
          merges.push(deny('`git -C` points at a shell variable, so the repository cannot be determined.'));
          return;
        }
        cwd = cwd ? resolve(cwd, value.text) : value.text;
      } else if (GIT_VALUE_FLAGS.has(text)) {
        i++;
      } else if (!text.startsWith('-')) {
        break;
      }
    }
    if (command[i]?.text === 'push') {
      analyzePush(command.slice(i + 1), cwd, run, merges);
    }
  }
}

// Returns one entry per merge the command would perform. Anything that looks like a merge
// but cannot be resolved comes back as { kind: 'deny' }.
export function findMerges(command: string, run: Runner = makeRunner()): Merge[] {
  const merges: Merge[] = [];
  for (const words of splitCommands(command)) {
    analyze(words, run, merges);
  }
  return merges;
}

const lines = (output: string): string[] => output.split(/\r?\n/).filter(Boolean);
const nulSeparated = (output: string): string[] => output.split('\0').filter(Boolean);

function pushFiles(merge: Extract<Located, { kind: 'push' }>, run: Runner): string[] {
  const git = (args: string[]) => run('git', [...at(merge.cwd), ...args]);
  const ref = `refs/heads/${merge.branch}`;
  const tip = lines(git(['ls-remote', merge.remote, ref]))
    .map((line) => line.split(/\s+/))
    .find(([, name]) => name === ref)?.[0];
  if (!tip) {
    throw new Error(`could not find ${ref} on ${merge.remote}`);
  }
  try {
    git(['cat-file', '-e', `${tip}^{commit}`]);
  } catch {
    throw new Error(
      `${merge.remote}/${merge.branch} is at ${tip.slice(0, 8)}, which is not fetched locally. Run git fetch first`
    );
  }
  // Compare trees directly (two dots) so a rewind that removes protected files is seen.
  // -z keeps odd filenames literal; --no-renames lists both sides of a move.
  return nulSeparated(git(['diff', '--name-only', '-z', '--no-renames', tip, merge.source, '--']));
}

type PrRef = { repo: string; number: string };

function resolvePr(merge: Extract<Located, { kind: 'pr' }>, run: Runner): PrRef {
  let repo = merge.repo;
  let number = merge.selector;
  if (!repo || !number || !/^\d+$/.test(number)) {
    if (number?.startsWith('-')) {
      throw new Error(`unexpected PR selector ${number}`);
    }
    const url = run('gh', [
      'pr',
      'view',
      ...(number ? [number] : []),
      ...(repo ? ['--repo', repo] : []),
      '--json',
      'url',
      '--jq',
      '.url',
    ]).trim();
    const match = url.match(/\/([^/]+)\/([^/]+)\/pull\/(\d+)$/);
    if (!match) {
      throw new Error(`could not resolve the PR from ${url || 'gh output'}`);
    }
    repo = `${match[1]}/${match[2]}`;
    number = match[3];
  }
  return { repo, number };
}

// The rule protects the default branch. A PR into any other branch (an integration branch, say)
// can be merged by an agent; the PR that later carries that branch into the default branch is
// gated here and read by a person. If the base cannot be read, the lookup throws and the merge
// is refused.
function landsOnDefaultBranch({ repo, number }: PrRef, run: Runner): boolean {
  const output = run('gh', [
    'api',
    `repos/${repo}/pulls/${number}`,
    '--jq',
    '[.base.ref, .base.repo.default_branch] | @json',
  ]).trim();
  const [base, defaultBranch] = JSON.parse(output) as [string?, string?];
  if (!base) {
    throw new Error(`could not read the base branch of ${repo}#${number}`);
  }
  return DEFAULT_BRANCHES.has(base) || base === defaultBranch;
}

function prFiles({ repo, number }: PrRef, run: Runner): string[] {
  // The files API reports previous_filename for renames, so a move out of config/ is seen.
  const output = run('gh', [
    'api',
    '--paginate',
    `repos/${repo}/pulls/${number}/files`,
    '--jq',
    '.[] | (.filename, .previous_filename // empty) | @json',
  ]);
  return lines(output).map((line) => JSON.parse(line) as string);
}

function changedFiles(merge: Located, run: Runner): string[] {
  if (merge.kind === 'push') {
    return pushFiles(merge, run);
  }
  const pr = resolvePr(merge, run);
  return landsOnDefaultBranch(pr, run) ? prFiles(pr, run) : [];
}

// Claude Code sends tool_name/tool_input; Copilot's camelCase events send toolName/toolArgs,
// where toolArgs may arrive as a JSON string.
type HookEvent = {
  tool_name?: string;
  toolName?: string;
  tool_input?: unknown;
  toolArgs?: unknown;
};

type ToolInput = {
  command?: string;
  owner?: string;
  repo?: string;
  pullNumber?: number | string;
  pull_number?: number | string;
};

function mergesFor(event: HookEvent, run: Runner): Merge[] {
  const tool = event.tool_name ?? event.toolName ?? '';
  const raw = event.tool_input ?? event.toolArgs ?? {};
  const input = (typeof raw === 'string' ? JSON.parse(raw) : raw) as ToolInput;
  if (/^(bash|powershell)$/i.test(tool)) {
    return findMerges(input.command ?? '', run);
  }
  if (/auto_?merge/i.test(tool)) {
    return [deny('enabling auto-merge merges later, after this check.')];
  }
  if (/merge_pull_request$/.test(tool)) {
    const repo = input.owner && input.repo ? `${input.owner}/${input.repo}` : undefined;
    return [{ kind: 'pr', repo, selector: String(input.pullNumber ?? input.pull_number ?? '') || undefined }];
  }
  return [];
}

export type Deps = { run?: Runner; listFiles?: (merge: Located) => string[] };

const refusal = (detail: string): string => `Merge blocked by AGENTS.md "Never merges without a human": ${detail}`;

export function decide(event: HookEvent, deps: Deps = {}): string | null {
  const run = deps.run ?? makeRunner();
  const listFiles = deps.listFiles ?? ((merge: Located) => changedFiles(merge, run));
  const blocked: string[] = [];
  try {
    for (const merge of mergesFor(event, run)) {
      if (merge.kind === 'deny') {
        return refusal(merge.reason);
      }
      blocked.push(...listFiles(merge).filter(isRiskPath));
    }
  } catch (error) {
    // Fail closed: if we cannot see what a merge changes, neither can we vouch for it.
    return `Merge blocked: could not verify what this merge changes (${messageOf(error)}).`;
  }
  if (blocked.length === 0) {
    return null;
  }
  return [
    'Merge blocked by AGENTS.md "Never merges without a human".',
    `This change touches: ${[...new Set(blocked)].join(', ')}.`,
    'Stop here and ask the user to read the diff and merge it themselves; standing approval does not count.',
  ].join(' ');
}

function emit(reason: string): void {
  const decision = { permissionDecision: 'deny', permissionDecisionReason: reason };
  // Copilot reads the decision at the top level; Claude Code nests it.
  const output = process.argv.includes('--copilot')
    ? decision
    : { hookSpecificOutput: { hookEventName: 'PreToolUse', ...decision } };
  process.stdout.write(JSON.stringify(output));
}

async function main(): Promise<void> {
  let reason: string | null;
  try {
    let raw = '';
    for await (const chunk of process.stdin) {
      raw += chunk;
    }
    reason = decide(JSON.parse(raw) as HookEvent);
  } catch (error) {
    // Claude Code only blocks on exit code 2; any other failure would let the call through.
    const message = `Merge gate failed (${messageOf(error)}); blocking to be safe.`;
    emit(message);
    process.stderr.write(message);
    process.exitCode = 2;
    return;
  }
  if (reason) {
    emit(reason);
  }
}

if (process.argv[1] && realpathSync(process.argv[1]) === fileURLToPath(import.meta.url)) {
  await main();
}
