import { spawnSync } from 'node:child_process';
import { fileURLToPath } from 'node:url';
import { describe, expect, it } from 'vitest';
import {
  decide,
  findMerges,
  isRiskPath,
  makeRunner,
  splitCommands,
  type Located,
  type Runner,
} from '../.claude/hooks/merge-gate.mts';

const HOOK = fileURLToPath(new URL('../.claude/hooks/merge-gate.mts', import.meta.url));

// A stand-in for git/gh: answers only the commands it was told about, fails on the rest.
const fake =
  (answers: Record<string, string> = {}): Runner =>
  (cmd, args) => {
    const key = [cmd, ...args].join(' ');
    if (key in answers) {
      return answers[key];
    }
    throw new Error(`unexpected: ${key}`);
  };
const onBranch = (branch: string, extra: Record<string, string> = {}) =>
  fake({ 'git symbolic-ref --short -q HEAD': `${branch}\n`, ...extra });

const denied = (command: string, run: Runner = fake()) => {
  const merges = findMerges(command, run);
  return merges.length === 1 && merges[0].kind === 'deny';
};

describe('isRiskPath', () => {
  it.each([
    'config/router.yaml',
    'ansible/site.yml',
    'infrastructure/main.tf',
    'mcp-config.json',
    '.vscode/mcp.json',
    '.gemini/settings.json',
    'Config/Router.yaml',
  ])('flags %s', (file) => expect(isRiskPath(file)).toBe(true));

  it.each(['docs/config/readme.md', 'scripts/lint-shell.mjs', 'myconfig/x', '.vscode/settings.json'])(
    'allows %s',
    (file) => expect(isRiskPath(file)).toBe(false)
  );
});

describe('splitCommands', () => {
  it('keeps a semicolon inside quotes', () => {
    const [command] = splitCommands('gh pr merge --body "Ready; reviewed" 42');
    expect(command.map((w) => w.text)).toEqual(['gh', 'pr', 'merge', '--body', 'Ready; reviewed', '42']);
  });

  it('splits on operators and subshell parentheses', () => {
    expect(splitCommands('a && b || c; echo $(d e) | f').map((c) => c.map((w) => w.text).join(' '))).toEqual([
      'a',
      'b',
      'c',
      'echo $',
      'd e',
      'f',
    ]);
  });

  it('marks expansions as dynamic, except in single quotes', () => {
    const [command] = splitCommands(`echo $PR "$PR" '$PR' plain`);
    expect(command.map((w) => w.dynamic)).toEqual([false, true, true, false, false]);
  });
});

describe('findMerges: gh', () => {
  it('reads the selector and repo from gh pr merge', () => {
    expect(findMerges('gh pr merge 42 --squash -R owner/repo --body "done"')).toEqual([
      { kind: 'pr', selector: '42', repo: 'owner/repo' },
    ]);
  });

  it('keeps the selector when the body holds a quoted semicolon', () => {
    expect(findMerges('gh pr merge --body "Ready; reviewed" 42')).toEqual([{ kind: 'pr', selector: '42' }]);
  });

  it('reads flags written as --flag=value', () => {
    expect(findMerges('gh pr merge --body="Ready to merge" --repo=o/r 42')).toEqual([
      { kind: 'pr', selector: '42', repo: 'o/r' },
    ]);
  });

  it.each(['gh -R o/r pr merge 42', 'gh pr -R o/r merge 42'])('finds the subcommand after options: %s', (command) => {
    expect(findMerges(command)).toEqual([{ kind: 'pr', selector: '42', repo: 'o/r' }]);
  });

  it('defaults to the current branch PR', () => {
    expect(findMerges('npm test && gh pr merge --squash')).toEqual([{ kind: 'pr' }]);
  });

  it('refuses --auto, which merges after the check', () => {
    expect(denied('gh pr merge 42 --auto --squash')).toBe(true);
  });

  it('allows cancelling auto-merge', () => {
    expect(findMerges('gh pr merge 42 --disable-auto')).toEqual([]);
  });

  it('refuses a PR number held in a variable', () => {
    expect(denied('gh pr merge $PR_NUMBER --squash')).toBe(true);
    expect(denied('gh pr merge "$(gh pr list -q .[0].number --json number)"')).toBe(true);
  });

  it('detects the REST merge endpoint', () => {
    expect(findMerges('gh api -X PUT repos/o/r/pulls/7/merge')).toEqual([{ kind: 'pr', repo: 'o/r', selector: '7' }]);
  });

  it('refuses a REST merge endpoint with an unresolved number', () => {
    expect(denied('gh api -X PUT repos/o/r/pulls/$PR/merge')).toBe(true);
  });

  it('refuses GraphQL merge mutations and default-branch ref moves', () => {
    expect(
      denied(
        'gh api graphql -f query="mutation { mergePullRequest(input: {pullRequestId: \\"x\\"}) { clientMutationId } }"'
      )
    ).toBe(true);
    expect(denied('gh api -X PATCH repos/o/r/git/refs/heads/master -f sha=abc')).toBe(true);
  });

  it('sees merges hidden in wrappers and nested shells', () => {
    for (const command of [
      'env GH_TOKEN=x gh pr merge 42',
      'bash -c "gh pr merge 42"',
      'echo $(gh pr merge 42)',
      'sudo -E /usr/bin/gh.exe pr merge 42',
      'pwsh -Command "gh pr merge 42"',
    ]) {
      expect(findMerges(command)).toEqual([{ kind: 'pr', selector: '42' }]);
    }
  });

  it('refuses an encoded command and a command held in a variable', () => {
    expect(denied('pwsh -EncodedCommand ZwBoACAAcAByACAAbQBlAHIAZwBlAA==')).toBe(true);
    expect(denied('$GH pr merge 42')).toBe(true);
  });

  it('ignores unrelated commands', () => {
    expect(findMerges('gh pr view 42; git merge-base HEAD master')).toEqual([]);
  });
});

describe('findMerges: git push', () => {
  it('detects an explicit push to the default branch', () => {
    expect(findMerges('git push origin HEAD:master')).toEqual([
      { kind: 'push', remote: 'origin', source: 'HEAD', branch: 'master' },
    ]);
    expect(findMerges('git push --force origin +topic:refs/heads/main')).toEqual([
      { kind: 'push', remote: 'origin', source: 'topic', branch: 'main' },
    ]);
  });

  it('uses the named source ref, not the checked-out branch', () => {
    expect(findMerges('git push origin master')).toEqual([
      { kind: 'push', remote: 'origin', source: 'master', branch: 'master' },
    ]);
  });

  it('finds push after git options and keeps the directory', () => {
    expect(findMerges('git -C ../other -c core.x=1 push origin HEAD:master')).toEqual([
      { kind: 'push', remote: 'origin', source: 'HEAD', branch: 'master', cwd: '../other' },
    ]);
  });

  it('ignores pushes to other branches without asking git anything', () => {
    expect(findMerges('git push -u origin agents/fix-1')).toEqual([]);
  });

  it('lets a bare push on a feature branch through', () => {
    expect(findMerges('git push', onBranch('feat/x'))).toEqual([]);
    expect(findMerges('git push origin', onBranch('feat/x'))).toEqual([]);
  });

  it('resolves a bare push on the default branch', () => {
    expect(findMerges('git push', onBranch('master'))).toEqual([
      { kind: 'push', remote: 'origin', source: 'master', branch: 'master' },
    ]);
  });

  it('resolves HEAD to the current branch', () => {
    expect(findMerges('git push origin HEAD', onBranch('master'))).toEqual([
      { kind: 'push', remote: 'origin', source: 'HEAD', branch: 'master' },
    ]);
    expect(findMerges('git push origin HEAD', onBranch('feat/x'))).toEqual([]);
  });

  it('follows the upstream when push.default says so', () => {
    const run = onBranch('feat/x', {
      'git config --get push.default': 'upstream\n',
      'git config --get branch.feat/x.merge': 'refs/heads/master\n',
    });
    expect(findMerges('git push', run)).toEqual([
      { kind: 'push', remote: 'origin', source: 'feat/x', branch: 'master' },
    ]);
  });

  it('refuses a bare push it cannot resolve', () => {
    expect(denied('git push', fake())).toBe(true);
    expect(denied('git push', onBranch('feat/x', { 'git config --get push.default': 'matching\n' }))).toBe(true);
  });

  it.each([
    'git push --all',
    'git push --mirror origin',
    'git push origin "refs/heads/*:refs/heads/*"',
    'git push origin $BRANCH',
    'git push origin --delete master',
    'git push origin :master',
    'git -C $DIR push origin master',
  ])('refuses %s', (command) => expect(denied(command)).toBe(true));
});

describe('decide', () => {
  const bash = (command: string) => ({ tool_name: 'Bash', tool_input: { command } });

  it('denies merges touching risk paths', () => {
    expect(decide(bash('gh pr merge 1'), { listFiles: () => ['docs/a.md', 'ansible/site.yml'] })).toMatch(
      /ansible\/site\.yml/
    );
  });

  it('allows merges outside risk paths', () => {
    expect(decide(bash('gh pr merge 1'), { listFiles: () => ['docs/a.md'] })).toBeNull();
  });

  it('explains a refusal that is not about files', () => {
    expect(decide(bash('gh pr merge 1 --auto'))).toMatch(/--auto.*merge immediately/);
  });

  it('gates the GitHub MCP merge tool', () => {
    const event = {
      tool_name: 'mcp__claude_ai_github__merge_pull_request',
      tool_input: { owner: 'o', repo: 'r', pullNumber: 3 },
    };
    let seen: Located | undefined;
    expect(
      decide(event, {
        listFiles: (m) => {
          seen = m;
          return ['.mcp.json'];
        },
      })
    ).toMatch(/\.mcp\.json/);
    expect(seen).toEqual({ kind: 'pr', repo: 'o/r', selector: '3' });
  });

  it('refuses MCP auto-merge tools', () => {
    expect(decide({ tool_name: 'mcp__github__enable_pull_request_auto_merge', tool_input: {} })).toMatch(/auto-merge/);
  });

  it('reads Copilot camelCase events with string toolArgs', () => {
    const event = { toolName: 'powershell', toolArgs: JSON.stringify({ command: 'gh pr merge 5' }) };
    expect(decide(event, { listFiles: () => ['config/vlan-registry.yaml'] })).toMatch(/config\/vlan-registry\.yaml/);
  });

  it('fails closed when the diff cannot be listed', () => {
    expect(
      decide(bash('gh pr merge 1'), {
        listFiles: () => {
          throw new Error('offline');
        },
      })
    ).toMatch(/could not verify.*offline/);
  });

  describe('listing a PR with gh', () => {
    const files = (out: string, number = '42') =>
      fake({
        [`gh api --paginate repos/o/r/pulls/${number}/files --jq .[] | (.filename, .previous_filename // empty) | @json`]:
          out,
      });

    it('sees the old path of a renamed file', () => {
      const run = files('"docs/router.yaml"\n"config/router.yaml"\n');
      expect(decide(bash('gh pr merge 42 -R o/r'), { run })).toMatch(/config\/router\.yaml/);
    });

    it('decodes JSON-escaped non-ASCII names', () => {
      expect(decide(bash('gh pr merge 42 -R o/r'), { run: files('"config/caf\\u00e9.yaml"\n') })).toMatch(
        /config\/café\.yaml/
      );
    });

    it('resolves the PR from the current branch first', () => {
      const run = fake({
        'gh pr view --json url --jq .url': 'https://github.com/o/r/pull/9\n',
        'gh api --paginate repos/o/r/pulls/9/files --jq .[] | (.filename, .previous_filename // empty) | @json':
          '"docs/a.md"\n',
      });
      expect(decide(bash('gh pr merge --squash'), { run })).toBeNull();
    });
  });

  describe('listing a push with git', () => {
    const TIP = 'a'.repeat(40);
    const push = (diff: string, extra: Record<string, string> = {}) =>
      fake({
        [`git ls-remote origin refs/heads/master`]: `${TIP}\trefs/heads/master\n`,
        [`git cat-file -e ${TIP}^{commit}`]: '',
        [`git diff --name-only -z --no-renames ${TIP} HEAD --`]: diff,
        ...extra,
      });

    it('compares the remote tip with the source, using NUL-separated names', () => {
      expect(decide(bash('git push origin HEAD:master'), { run: push('docs/a.md\0config/café.yaml\0') })).toMatch(
        /config\/café\.yaml/
      );
      expect(decide(bash('git push origin HEAD:master'), { run: push('docs/a.md\0') })).toBeNull();
    });

    it('fails closed when the remote tip is not fetched locally', () => {
      const run = fake({ 'git ls-remote origin refs/heads/master': `${TIP}\trefs/heads/master\n` });
      expect(decide(bash('git push origin HEAD:master'), { run })).toMatch(/not fetched locally/);
    });

    it('fails closed when the remote branch cannot be found', () => {
      expect(
        decide(bash('git push origin HEAD:master'), { run: fake({ 'git ls-remote origin refs/heads/master': '' }) })
      ).toMatch(/could not find/);
    });
  });
});

describe('makeRunner', () => {
  it('refuses to start a lookup after the deadline', () => {
    expect(() => makeRunner(-1)('git', ['--version'])).toThrow(/deadline/);
  });

  it('runs a command inside the deadline', () => {
    expect(makeRunner(10_000)('git', ['--version'])).toMatch(/^git version/);
  });
});

describe('the hook as a process', () => {
  const run = (input: string, args: string[] = []) =>
    spawnSync(process.execPath, [HOOK, ...args], { input, encoding: 'utf8' });

  it('stays silent for a tool call it does not gate', () => {
    const result = run(JSON.stringify({ tool_name: 'Read', tool_input: { file_path: 'x' } }));
    expect(result).toMatchObject({ status: 0, stdout: '' });
  });

  it('denies in Claude Code and Copilot shapes', () => {
    const event = JSON.stringify({
      tool_name: 'Bash',
      toolName: 'bash',
      tool_input: { command: 'gh pr merge 1 --auto' },
    });
    expect(JSON.parse(run(event).stdout).hookSpecificOutput.permissionDecision).toBe('deny');
    expect(JSON.parse(run(event, ['--copilot']).stdout).permissionDecision).toBe('deny');
  });

  it('exits 2 when it cannot read its input, so Claude Code blocks', () => {
    const result = run('not json');
    expect(result.status).toBe(2);
    expect(JSON.parse(result.stdout).hookSpecificOutput.permissionDecision).toBe('deny');
    expect(result.stderr).toMatch(/blocking to be safe/);
  });
});
