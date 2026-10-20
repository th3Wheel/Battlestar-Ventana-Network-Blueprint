// Regression tests for the repository's ESLint configuration.
import { ESLint } from 'eslint';
import { resolve } from 'node:path';
import { describe, expect, it } from 'vitest';

const repositoryRoot = process.cwd();
const eslint = new ESLint({ cwd: repositoryRoot });

describe('repository ESLint configuration', () => {
  it('reports configured correctness and style violations', async () => {
    const [result] = await eslint.lintText(
      `const unused = 1;
if (unknown == 1) console.log('lint');
`,
      { filePath: resolve('tests/eslint-fixture.js') }
    );

    expect(result.messages).toEqual(
      expect.arrayContaining([
        expect.objectContaining({ ruleId: 'no-unused-vars', severity: 1 }),
        expect.objectContaining({ ruleId: 'no-undef', severity: 2 }),
        expect.objectContaining({ ruleId: 'eqeqeq', severity: 2 }),
        expect.objectContaining({ ruleId: 'curly', severity: 2 }),
      ])
    );
  }, 15000);

  it('applies the recommended Markdown rules', async () => {
    const [result] = await eslint.lintText('#No space\n', {
      filePath: resolve('tests/eslint-fixture.md'),
    });

    expect(result.messages).toContainEqual(
      expect.objectContaining({
        ruleId: 'markdown/no-missing-atx-heading-space',
        severity: 2,
      })
    );
  });
});
