// Fails when a file that belongs to one machine or person (per-machine settings, secrets,
// keys) is tracked or about to be merged. The list lives in .github/local-files-policy.json
// so changing it goes through CODEOWNERS review.
//
//   node scripts/check-local-files.ts --tracked          every tracked file
//   node scripts/check-local-files.ts --base <ref>       files a branch adds or changes vs <ref>
//
// Exit 0 clean, 1 violations found, 2 could not decide (bad policy, git failure): fail closed.
import { spawnSync } from 'node:child_process';
import { readFileSync, realpathSync } from 'node:fs';
import { fileURLToPath } from 'node:url';

export interface ForbiddenRule {
  pattern: string;
  reason: string;
}
export interface AllowedRule {
  path: string;
  reason: string;
}
export interface Policy {
  forbidden: ForbiddenRule[];
  allowed: AllowedRule[];
}
export interface Violation {
  file: string;
  pattern: string;
  reason: string;
}

const POLICY_PATH = fileURLToPath(new URL('../.github/local-files-policy.json', import.meta.url));

const isRecord = (value: unknown): value is Record<string, unknown> =>
  typeof value === 'object' && value !== null && !Array.isArray(value);

const text = (value: unknown, where: string): string => {
  if (typeof value !== 'string' || value.trim() === '') {
    throw new Error(`${where} must be a non-empty string`);
  }
  return value;
};

// The matcher below understands `*`, `**` and `?` only. Anything else is rejected when the
// policy loads: a rule written with a character class or braces would otherwise never match,
// and nobody would notice that the check had stopped enforcing it.
const UNSUPPORTED_GLOB_CHARS = `[]{}()!${String.fromCharCode(92)}`;
const glob = (value: unknown, where: string): string => {
  const pattern = text(value, where);
  const unsupported = [...pattern].find((char) => UNSUPPORTED_GLOB_CHARS.includes(char));
  if (unsupported) {
    throw new Error(`${where} uses unsupported glob syntax "${unsupported}"; only *, ** and ? are understood`);
  }
  return pattern;
};

// Every rule must say why it exists: a list nobody can justify is a list nobody dares edit.
export function parsePolicy(raw: unknown): Policy {
  if (!isRecord(raw) || !Array.isArray(raw.forbidden) || !Array.isArray(raw.allowed)) {
    throw new Error('policy must be an object with "forbidden" and "allowed" arrays');
  }
  if (raw.forbidden.length === 0) {
    throw new Error('policy "forbidden" must not be empty');
  }
  const forbidden = raw.forbidden.map((rule: unknown, i) => {
    if (!isRecord(rule)) {
      throw new Error(`forbidden[${i}] must be an object`);
    }
    return {
      pattern: glob(rule.pattern, `forbidden[${i}].pattern`),
      reason: text(rule.reason, `forbidden[${i}].reason`),
    };
  });
  const allowed = raw.allowed.map((rule: unknown, i) => {
    if (!isRecord(rule)) {
      throw new Error(`allowed[${i}] must be an object`);
    }
    return {
      path: glob(rule.path, `allowed[${i}].path`),
      reason: text(rule.reason, `allowed[${i}].reason`),
    };
  });
  return { forbidden, allowed };
}

export function loadPolicy(path = POLICY_PATH): Policy {
  return parsePolicy(JSON.parse(readFileSync(path, 'utf8')));
}

const ESCAPE = String.fromCharCode(92); // a single backslash
const REGEX_SPECIALS = '.+^$(){}|[]';

// Node's path.matchesGlob lets `**` skip dot-directories, so `**/settings.local.json` would
// miss `.claude/settings.local.json`, the very file this policy exists for. This matcher treats
// dot-names like any other: `**/` is any directories (or none), `*` stays inside one segment.
export function globToRegExp(glob: string): RegExp {
  let source = '';
  for (let i = 0; i < glob.length; i++) {
    const char = glob[i];
    if (char === '*' && glob[i + 1] === '*') {
      const slash = glob[i + 2] === '/';
      source += slash ? '(?:.*/)?' : '.*';
      i += slash ? 2 : 1;
    } else if (char === '*') {
      source += '[^/]*';
    } else if (char === '?') {
      source += '[^/]';
    } else {
      source += REGEX_SPECIALS.includes(char) ? ESCAPE + char : char;
    }
  }
  return new RegExp(`^${source}$`);
}
export const matchesGlob = (file: string, glob: string) => globToRegExp(glob).test(file);

const normalize = (file: string) => file.replaceAll(ESCAPE, '/').replace(/^\.\//, '');

export function findViolations(files: string[], policy: Policy): Violation[] {
  const violations: Violation[] = [];
  for (const raw of files) {
    const file = normalize(raw);
    if (policy.allowed.some((rule) => matchesGlob(file, rule.path))) {
      continue;
    }
    const rule = policy.forbidden.find((candidate) => matchesGlob(file, candidate.pattern));
    if (rule) {
      violations.push({ file, pattern: rule.pattern, reason: rule.reason });
    }
  }
  return violations;
}

function gitLines(args: string[]): string[] {
  const result = spawnSync('git', args, { encoding: 'utf8' });
  if (result.status !== 0) {
    throw new Error((result.stderr || result.error?.message || `git ${args.join(' ')} failed`).trim());
  }
  return result.stdout.split(/\r?\n/).filter(Boolean);
}

// Added, copied, modified and renamed files: a PR that deletes a forbidden file is fixing it.
export const changedSince = (base: string) => gitLines(['diff', '--name-only', '--diff-filter=ACMR', `${base}...HEAD`]);
export const trackedFiles = () => gitLines(['ls-files']);

function main(argv: string[]): number {
  const baseAt = argv.indexOf('--base');
  const base = baseAt === -1 ? undefined : argv[baseAt + 1];
  if (!argv.includes('--tracked') && !base) {
    console.error('usage: check-local-files.ts --tracked | --base <ref>');
    return 2;
  }
  try {
    const policy = loadPolicy();
    const files = [...(argv.includes('--tracked') ? trackedFiles() : []), ...(base ? changedSince(base) : [])];
    const violations = findViolations([...new Set(files)], policy);
    for (const v of violations) {
      console.error(`::error file=${v.file}::Local file must not be committed (${v.pattern}): ${v.reason}`);
    }
    if (violations.length > 0) {
      console.error(
        `\n${violations.length} local file(s) found. Remove them from the commit (git rm --cached <file>) ` +
          'and keep them ignored. If a file is a legitimate shared template, a person adds it to ' +
          '"allowed" in .github/local-files-policy.json with a reason.'
      );
      return 1;
    }
    return 0;
  } catch (error) {
    console.error(`Could not check for local files: ${error instanceof Error ? error.message : error}`);
    return 2;
  }
}

if (process.argv[1] && realpathSync(process.argv[1]) === fileURLToPath(import.meta.url)) {
  process.exitCode = main(process.argv.slice(2));
}
