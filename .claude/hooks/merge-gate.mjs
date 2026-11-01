// PreToolUse hook: refuses agent-driven merges that touch the paths AGENTS.md
// lists under "Never merges without a human". A person merges those themselves.
import { spawnSync } from 'node:child_process';
import { realpathSync } from 'node:fs';
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
// gh pr merge flags that take a value, so their value is not mistaken for the PR selector.
const GH_VALUE_FLAGS = new Set([
    '-R', '--repo', '-t', '--subject', '-b', '--body', '-F', '--body-file',
    '-A', '--author-email', '--match-head-commit',
]);
export function isRiskPath(file) {
    const path = file.replaceAll('\\', '/').replace(/^\.\//, '');
    return RISK_FILES.has(path) || RISK_PREFIXES.some((prefix) => path.startsWith(prefix));
}
function tokenize(segment) {
    return [...segment.matchAll(/"([^"]*)"|'([^']*)'|(\S+)/g)].map((m) => m[1] ?? m[2] ?? m[3]);
}
export function findMerges(command) {
    const merges = [];
    for (const segment of command.split(/&&|\|\||[;|\n]/)) {
        const tokens = tokenize(segment);
        const at = (i, value) => tokens[i] === value;
        for (let i = 0; i < tokens.length; i++) {
            if (at(i, 'gh') && at(i + 1, 'pr') && at(i + 2, 'merge')) {
                const merge = { kind: 'pr' };
                for (let j = i + 3; j < tokens.length; j++) {
                    const token = tokens[j];
                    if (token === '-R' || token === '--repo') {
                        merge.repo = tokens[++j];
                    }
                    else if (token.startsWith('--repo=')) {
                        merge.repo = token.slice(7);
                    }
                    else if (GH_VALUE_FLAGS.has(token)) {
                        j++;
                    }
                    else if (!token.startsWith('-') && merge.selector === undefined) {
                        merge.selector = token;
                    }
                }
                merges.push(merge);
            }
            if (at(i, 'gh') && at(i + 1, 'api')) {
                const endpoint = tokens.slice(i + 2).find((t) => /pulls\/\d+\/merge$/.test(t));
                const match = endpoint?.match(/repos\/([^/]+\/[^/]+)\/pulls\/(\d+)\/merge$/);
                if (match) {
                    merges.push({ kind: 'pr', repo: match[1], selector: match[2] });
                }
            }
            if (at(i, 'git') && at(i + 1, 'push')) {
                const args = tokens.slice(i + 2).filter((t) => !t.startsWith('-'));
                const [remote = 'origin', ...refspecs] = args;
                for (const refspec of refspecs) {
                    const [source, target = source] = refspec.replace(/^\+/, '').split(':');
                    const branch = target.replace(/^refs\/heads\//, '');
                    if (DEFAULT_BRANCHES.has(branch)) {
                        merges.push({ kind: 'push', remote, source: source || 'HEAD', branch });
                    }
                }
            }
        }
    }
    return merges;
}
function run(cmd, args) {
    const result = spawnSync(cmd, args, { encoding: 'utf8' });
    if (result.status !== 0) {
        throw new Error((result.stderr || result.error?.message || `${cmd} failed`).trim());
    }
    return result.stdout.split(/\r?\n/).filter(Boolean);
}
function changedFiles(merge) {
    if (merge.kind === 'push') {
        const source = merge.source === merge.branch ? 'HEAD' : merge.source;
        return run('git', ['diff', '--name-only', `${merge.remote}/${merge.branch}...${source}`]);
    }
    const args = ['pr', 'diff', '--name-only'];
    if (merge.selector) {
        args.push(merge.selector);
    }
    if (merge.repo) {
        args.push('--repo', merge.repo);
    }
    return run('gh', args);
}
function mergesFor(event) {
    const tool = event.tool_name ?? event.toolName;
    const raw = event.tool_input ?? event.toolArgs ?? {};
    const input = (typeof raw === 'string' ? JSON.parse(raw) : raw);
    if (/^(bash|powershell)$/i.test(tool ?? '')) {
        return findMerges(input.command ?? '');
    }
    if (/merge_pull_request$/.test(tool ?? '')) {
        const repo = input.owner && input.repo ? `${input.owner}/${input.repo}` : undefined;
        return [{ kind: 'pr', repo, selector: String(input.pullNumber ?? input.pull_number ?? '') || undefined }];
    }
    return [];
}
export function decide(event, listFiles = changedFiles) {
    const blocked = [];
    for (const merge of mergesFor(event)) {
        let files;
        try {
            files = listFiles(merge);
        }
        catch (error) {
            const message = error instanceof Error ? error.message : String(error);
            // Fail closed: if we cannot see the diff, neither can we vouch for it.
            return `Merge blocked: could not list the files this merge changes (${message}).`;
        }
        blocked.push(...files.filter(isRiskPath));
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
async function main() {
    let raw = '';
    for await (const chunk of process.stdin) {
        raw += chunk;
    }
    const reason = decide(JSON.parse(raw));
    if (!reason) {
        return;
    }
    const decision = { permissionDecision: 'deny', permissionDecisionReason: reason };
    // Copilot reads the decision at the top level; Claude Code nests it.
    const output = process.argv.includes('--copilot')
        ? decision
        : { hookSpecificOutput: { hookEventName: 'PreToolUse', ...decision } };
    process.stdout.write(JSON.stringify(output));
}
if (process.argv[1] && realpathSync(process.argv[1]) === fileURLToPath(import.meta.url)) {
    await main();
}
