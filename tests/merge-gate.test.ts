import { describe, expect, it } from 'vitest';
import { decide, findMerges, isRiskPath } from '../.claude/hooks/merge-gate.mts';

describe('isRiskPath', () => {
  it.each(['config/router.yaml', 'ansible/site.yml', 'infrastructure/main.tf', 'mcp-config.json', '.vscode/mcp.json', '.gemini/settings.json'])(
    'flags %s', (file) => expect(isRiskPath(file)).toBe(true),
  );

  it.each(['docs/config/readme.md', 'scripts/lint-shell.mjs', 'myconfig/x', '.vscode/settings.json'])(
    'allows %s', (file) => expect(isRiskPath(file)).toBe(false),
  );
});

describe('findMerges', () => {
  it('reads the selector and repo from gh pr merge', () => {
    expect(findMerges('gh pr merge 42 --squash -R owner/repo --body "done"')).toEqual([
      { kind: 'pr', selector: '42', repo: 'owner/repo' },
    ]);
  });

  it('defaults to the current branch PR', () => {
    expect(findMerges('npm test && gh pr merge --auto --squash')).toEqual([{ kind: 'pr' }]);
  });

  it('detects the REST merge endpoint', () => {
    expect(findMerges('gh api -X PUT repos/o/r/pulls/7/merge')).toEqual([{ kind: 'pr', repo: 'o/r', selector: '7' }]);
  });

  it('detects pushes to the default branch only', () => {
    expect(findMerges('git push origin HEAD:master')).toEqual([{ kind: 'push', remote: 'origin', source: 'HEAD', branch: 'master' }]);
    expect(findMerges('git push -u origin agents/fix-1')).toEqual([]);
  });

  it('ignores unrelated commands', () => {
    expect(findMerges('gh pr view 42; git merge-base HEAD master')).toEqual([]);
  });
});

describe('decide', () => {
  const bash = (command: string) => ({ tool_name: 'Bash', tool_input: { command } });

  it('denies merges touching risk paths', () => {
    expect(decide(bash('gh pr merge 1'), () => ['docs/a.md', 'ansible/site.yml'])).toMatch(/ansible\/site\.yml/);
  });

  it('allows merges outside risk paths', () => {
    expect(decide(bash('gh pr merge 1'), () => ['docs/a.md'])).toBeNull();
  });

  it('gates the GitHub MCP merge tool', () => {
    const event = { tool_name: 'mcp__claude_ai_github__merge_pull_request', tool_input: { owner: 'o', repo: 'r', pullNumber: 3 } };
    let seen;
    expect(decide(event, (m) => { seen = m; return ['.mcp.json']; })).toMatch(/\.mcp\.json/);
    expect(seen).toEqual({ kind: 'pr', repo: 'o/r', selector: '3' });
  });

  it('reads Copilot camelCase events with string toolArgs', () => {
    const event = { toolName: 'powershell', toolArgs: JSON.stringify({ command: 'gh pr merge 5' }) };
    expect(decide(event, () => ['config/vlan-registry.yaml'])).toMatch(/config\/vlan-registry\.yaml/);
  });

  it('fails closed when the diff cannot be listed', () => {
    expect(decide(bash('gh pr merge 1'), () => { throw new Error('offline'); })).toMatch(/could not list/);
  });
});
