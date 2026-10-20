// Regression tests for: prettier@3.7.4 upgrade.
import * as prettier from 'prettier';
import { describe, expect, it } from 'vitest';

describe('Prettier JavaScript formatting', () => {
  it('formats JavaScript through the documented API', async () => {
    const formatted = await prettier.format('const answer=42', { parser: 'babel' });

    expect(formatted).toBe('const answer = 42;\n');
  });

  describe('Prettier yamllint configuration', () => {
    it('formats extensionless yamllint files using the repository configuration', async () => {
      const filePath = '.yamllint';
      const options = await prettier.resolveConfig(filePath);

      expect(options.parser).toBe('yaml');
      const formatted = await prettier.format('rules: {document-start: disable}\n', {
        ...options,
        filepath: filePath,
      });

      expect(formatted).toBe('rules: { document-start: disable }\n');
    });
  });
});
