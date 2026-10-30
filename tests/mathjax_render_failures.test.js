import { describe, expect, it } from 'vitest';
import {
  isInsideMathSource,
  makeTermVector,
  replaceUniqueMathExpression,
  tokenizeLatex,
} from '../tools/mathjax_render_failures.mjs';

describe('MathJax render failure helpers', () => {
  it('tokenizes LaTeX commands and builds a frequency vector', () => {
    const latex = String.raw`\frac{x_1}{2}`;

    expect(tokenizeLatex(latex)).toEqual([
      '\\frac', '{', 'x', '_', '1', '}', '{', '2', '}',
    ]);
    expect(makeTermVector(latex).counts).toEqual({
      '\\frac': 1,
      '1': 1,
      '2': 1,
      '{': 2,
      '}': 2,
      '_': 1,
      x: 1,
    });
  });

  it('recognizes inline, display, and MyST math blocks', () => {
    const latex = String.raw`\badCommand{x}`;
    const sources = [
      `Inline $${latex}$.`,
      `$$\n${latex}\n$$`,
      `\`\`\`{math}\n${latex}\n\`\`\``,
    ];

    for (const source of sources) {
      const index = source.indexOf(latex);
      expect(isInsideMathSource(source, index, latex.length)).toBe(true);
    }
  });

  it('does not treat code-fence contents as fixable math', () => {
    const latex = String.raw`\badCommand{x}`;
    const source = `\`\`\`lean\n${latex}\n\`\`\``;
    const index = source.indexOf(latex);

    expect(isInsideMathSource(source, index, latex.length)).toBe(false);
  });

  it('applies exact replacements only for a unique math expression', () => {
    const invalid = String.raw`\badCommand{x}`;
    const corrected = String.raw`\mathrm{x}`;
    const source = `Equation $${invalid}$.`;

    expect(replaceUniqueMathExpression(source, invalid, corrected)).toEqual({
      changed: true,
      source: `Equation $${corrected}$.`,
    });
    expect(
      replaceUniqueMathExpression(`${source}\nAgain $${invalid}$.`, invalid, corrected),
    ).toMatchObject({ changed: false });
    expect(
      replaceUniqueMathExpression(`\`\`\`lean\n${invalid}\n\`\`\``, invalid, corrected),
    ).toMatchObject({ changed: false });
    expect(replaceUniqueMathExpression(source, '', corrected)).toMatchObject({
      changed: false,
    });
  });
});