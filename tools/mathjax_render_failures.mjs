#!/usr/bin/env node

import { createRequire } from 'node:module';
import { dirname, join, relative, resolve, sep } from 'node:path';
import { fileURLToPath } from 'node:url';
import { chmod, mkdir, readFile, readdir, stat, writeFile } from 'node:fs/promises';

const scriptDir = dirname(fileURLToPath(import.meta.url));
const workspaceRoot = resolve(scriptDir, '..');

export function tokenizeLatex(latex) {
  return latex.match(/\\(?:[A-Za-z]+|.)|[\p{L}]+|\d+(?:\.\d+)?|[^\s]/gu) || [];
}

export function makeTermVector(latex) {
  const tokens = tokenizeLatex(latex);
  const counts = {};
  for (const token of tokens) counts[token] = (counts[token] || 0) + 1;
  return {
    tokens,
    counts: Object.fromEntries(
      Object.entries(counts).sort(([left], [right]) => left.localeCompare(right)),
    ),
  };
}

export function collectRenderedMathFailures() {
  const failures = [];
  const sourceFor = (node) =>
    node.closest('mjx-math')?.getAttribute('data-latex') ||
    node.closest('mjx-container')?.querySelector('mjx-math')?.getAttribute('data-latex') ||
    '';

  for (const node of document.querySelectorAll('mjx-merror')) {
    failures.push({
      kind: 'tex-parse-error',
      latex: sourceFor(node),
      fragment: node.getAttribute('data-latex') || '',
      message: node.getAttribute('data-mjx-error') || node.textContent?.trim() || 'MathJax parse error',
    });
  }

  for (const node of document.querySelectorAll('mjx-mtext[style]')) {
    const fragment = node.getAttribute('data-latex') || '';
    if (node.style.color.toLowerCase() !== 'red' || !/\\[A-Za-z]/.test(fragment)) continue;
    failures.push({
      kind: 'undefined-control-sequence',
      latex: sourceFor(node),
      fragment,
      message: `MathJax rendered an unknown control sequence as red text: ${fragment}`,
    });
  }

  const unique = new Map();
  for (const failure of failures) {
    const key = `${failure.kind}\u0000${failure.latex}\u0000${failure.fragment}`;
    unique.set(key, failure);
  }

  return {
    sourceMathCount: document.querySelectorAll('.math').length,
    renderedMathCount: document.querySelectorAll('mjx-container').length,
    failures: [...unique.values()],
  };
}

function parseArgs(argv) {
  const options = {
    htmlRoot: resolve(workspaceRoot, 'docs/_build/html'),
    sourceRoot: resolve(workspaceRoot, 'docs'),
    baseUrl: 'http://localhost:5173/',
    reportPath: resolve(workspaceRoot, '.tmp/mathjax-render-failures.json'),
    fixMapPath: null,
    applyFixes: false,
    timeout: 20000,
  };

  for (let index = 0; index < argv.length; index += 1) {
    const argument = argv[index];
    const value = () => {
      const next = argv[index + 1];
      if (!next || next.startsWith('--')) throw new Error(`Missing value for ${argument}`);
      index += 1;
      return next;
    };

    switch (argument) {
      case '--root': options.htmlRoot = resolve(workspaceRoot, value()); break;
      case '--source-root': options.sourceRoot = resolve(workspaceRoot, value()); break;
      case '--base-url': options.baseUrl = value(); break;
      case '--report': options.reportPath = resolve(workspaceRoot, value()); break;
      case '--fix-map': options.fixMapPath = resolve(workspaceRoot, value()); break;
      case '--timeout': options.timeout = Number(value()); break;
      case '--apply-fixes': options.applyFixes = true; break;
      case '--help': options.help = true; break;
      default: throw new Error(`Unknown option: ${argument}`);
    }
  }

  if (options.applyFixes && !options.fixMapPath) {
    throw new Error('--apply-fixes requires --fix-map with exact LaTeX replacements');
  }
  if (!Number.isFinite(options.timeout) || options.timeout <= 0) {
    throw new Error('--timeout must be a positive number of milliseconds');
  }
  return options;
}

function printHelp() {
  console.log(`Usage: node tools/mathjax_render_failures.mjs [options]

Scan built Sphinx HTML through a running site and report MathJax parse failures.

Options:
  --root DIR          Built HTML root (default: docs/_build/html)
  --source-root DIR   Markdown/RST source root (default: docs)
  --base-url URL      Site URL (default: http://localhost:5173/)
  --report FILE       JSON report (default: .tmp/mathjax-render-failures.json)
  --timeout MS        MathJax startup timeout per page (default: 20000)
  --fix-map FILE      JSON object mapping exact failed LaTeX to replacement LaTeX
  --apply-fixes       Apply unique mapped expressions in recognized math source only
  --help              Show this help

Example fix map:
  { "\\\\notACommand{x}": "\\\\mathrm{x}" }
`);
}

async function findMathPages(root) {
  const pages = [];
  const excluded = new Set(['_static', '_sources', '_modules']);

  async function visit(directory) {
    for (const entry of await readdir(directory, { withFileTypes: true })) {
      if (entry.isDirectory()) {
        if (!excluded.has(entry.name) && !entry.name.startsWith('.')) {
          await visit(join(directory, entry.name));
        }
      } else if (entry.isFile() && entry.name.endsWith('.html')) {
        const htmlPath = join(directory, entry.name);
        const html = await readFile(htmlPath, 'utf8');
        if (/class=["'][^"']*\bmath\b/.test(html)) pages.push(htmlPath);
      }
    }
  }

  await visit(root);
  return pages.sort();
}

async function resolveSourceFile(htmlRoot, sourceRoot, htmlPath) {
  const pageRelative = relative(htmlRoot, htmlPath).split(sep).join('/');
  const stem = pageRelative.slice(0, -'.html'.length);
  const sourceMapRoot = join(htmlRoot, '_sources');

  for (const extension of ['.md.txt', '.rst.txt', '.txt']) {
    const mappedPath = join(sourceMapRoot, `${stem}${extension}`);
    try {
      await stat(mappedPath);
      const sourceRelative = relative(sourceMapRoot, mappedPath).replace(/\.txt$/, '');
      const sourcePath = resolve(sourceRoot, sourceRelative);
      if (sourcePath.startsWith(`${resolve(sourceRoot)}${sep}`)) return sourcePath;
    } catch (error) {
      if (error.code !== 'ENOENT') throw error;
    }
  }

  for (const extension of ['.md', '.rst', '.txt']) {
    const sourcePath = resolve(sourceRoot, `${stem}${extension}`);
    try {
      await stat(sourcePath);
      return sourcePath;
    } catch (error) {
      if (error.code !== 'ENOENT') throw error;
    }
  }
  return null;
}

function findSourceLine(source, expression, fragment) {
  let index = expression ? source.indexOf(expression) : -1;
  if (index < 0 && fragment) index = source.indexOf(fragment);
  if (index < 0) return null;
  return source.slice(0, index).split('\n').length;
}

function codeFenceAt(source, targetIndex) {
  let activeFence = null;
  let offset = 0;
  for (const line of source.split(/(?<=\n)/)) {
    if (offset > targetIndex) break;
    const match = line.match(/^\s*(`{3,}|~{3,})\s*(.*?)\s*(?:\r?\n)?$/);
    if (match) {
      const marker = match[1];
      if (!activeFence) {
        activeFence = {
          marker,
          isMath: /^(?:\{math\}|math(?:\s|$))/.test(match[2]),
        };
      } else if (
        marker[0] === activeFence.marker[0] &&
        marker.length >= activeFence.marker.length
      ) {
        activeFence = null;
      }
    }
    offset += line.length;
  }
  return activeFence;
}

function mathRanges(source) {
  const ranges = [];
  const patterns = [
    /\\\[([\s\S]*?)\\\]/g,
    /\\\(([\s\S]*?)\\\)/g,
    /\$\$([\s\S]*?)\$\$/g,
    /(?<!\\)\$(?!\$)([^\n]*?)(?<!\\)\$(?!\$)/g,
    /\\begin\{(?:equation|align|gather|multline|eqnarray)\*?\}([\s\S]*?)\\end\{(?:equation|align|gather|multline|eqnarray)\*?\}/g,
  ];

  for (const pattern of patterns) {
    for (const match of source.matchAll(pattern)) {
      const contentOffset = match[0].indexOf(match[1]);
      ranges.push([match.index + contentOffset, match.index + contentOffset + match[1].length]);
    }
  }

  const lines = source.split(/(?<=\n)/);
  let offset = 0;
  let activeFence = null;
  for (const line of lines) {
    const match = line.match(/^\s*(`{3,}|~{3,})\s*(.*?)\s*(?:\r?\n)?$/);
    if (match) {
      const marker = match[1];
      if (!activeFence) {
        activeFence = {
          marker,
          isMath: /^(?:\{math\}|math(?:\s|$))/.test(match[2]),
          contentStart: offset + line.length,
        };
      } else if (
        marker[0] === activeFence.marker[0] &&
        marker.length >= activeFence.marker.length
      ) {
        if (activeFence.isMath) ranges.push([activeFence.contentStart, offset]);
        activeFence = null;
      }
    }
    offset += line.length;
  }

  return ranges;
}

export function isInsideMathSource(source, index, length) {
  const fence = codeFenceAt(source, index);
  if (fence && !fence.isMath) return false;
  return mathRanges(source).some(([start, end]) => index >= start && index + length <= end);
}

export function replaceUniqueMathExpression(source, oldLatex, newLatex) {
  if (!oldLatex) return { changed: false, reason: 'failed expression has no source LaTeX' };

  const matches = [];
  let from = 0;
  while (from < source.length) {
    const index = source.indexOf(oldLatex, from);
    if (index < 0) break;
    if (isInsideMathSource(source, index, oldLatex.length)) matches.push(index);
    from = index + oldLatex.length;
  }

  if (matches.length !== 1) {
    return { changed: false, reason: `expected one math-source match, found ${matches.length}` };
  }

  const index = matches[0];
  return {
    changed: true,
    source: source.slice(0, index) + newLatex + source.slice(index + oldLatex.length),
  };
}

async function scanPages(options) {
  const requireFromE2E = createRequire(join(workspaceRoot, 'e2e/package.json'));
  let chromium;
  try {
    ({ chromium } = requireFromE2E('playwright'));
  } catch (error) {
    throw new Error(`Playwright is required; install dependencies in e2e/. ${error.message}`);
  }

  const pages = await findMathPages(options.htmlRoot);
  if (!pages.length) throw new Error(`No math-containing HTML pages found under ${options.htmlRoot}`);

  const browser = await chromium.launch({ headless: true });
  const failures = [];
  const browserErrors = [];
  const unscannedPages = [];
  const baseUrl = options.baseUrl.endsWith('/') ? options.baseUrl : `${options.baseUrl}/`;

  try {
    for (const htmlPath of pages) {
      const pageRelative = relative(options.htmlRoot, htmlPath).split(sep).join('/');
      const pageUrl = new URL(pageRelative.split('/').map(encodeURIComponent).join('/'), baseUrl).href;
      const page = await browser.newPage();
      const sourcePath = await resolveSourceFile(options.htmlRoot, options.sourceRoot, htmlPath);
      const pageErrors = [];
      page.on('pageerror', (error) => pageErrors.push(error.message));
      page.on('console', (message) => {
        if (message.type() === 'error') pageErrors.push(message.text());
      });

      try {
        await page.goto(pageUrl, { waitUntil: 'domcontentloaded', timeout: options.timeout });
        await page.waitForFunction(
          () => window.MathJax && typeof window.MathJax.typesetPromise === 'function',
          null,
          { timeout: options.timeout },
        );
        await page.evaluate(async () => {
          if (window.MathJax.startup?.promise) await window.MathJax.startup.promise;
          await window.MathJax.typesetPromise();
        });

        const result = await page.evaluate(collectRenderedMathFailures);
        const source = sourcePath ? await readFile(sourcePath, 'utf8') : '';
        for (const failure of result.failures) {
          failures.push({
            page: pageRelative,
            source: sourcePath ? relative(workspaceRoot, sourcePath).split(sep).join('/') : null,
            sourceLine: source ? findSourceLine(source, failure.latex, failure.fragment) : null,
            kind: failure.kind,
            message: failure.message,
            latex: failure.latex,
            fragment: failure.fragment,
            termVector: makeTermVector(failure.latex || failure.fragment),
          });
        }

        if (result.sourceMathCount && !result.renderedMathCount) {
          unscannedPages.push({ page: pageRelative, error: 'MathJax initialized but rendered no math output' });
        }
      } catch (error) {
        unscannedPages.push({ page: pageRelative, error: error.message });
      } finally {
        if (pageErrors.length) browserErrors.push({ page: pageRelative, errors: pageErrors });
        await page.close();
      }
    }
  } finally {
    await browser.close();
  }

  return { pages, failures, browserErrors, unscannedPages };
}

async function applyFixes(failures, options) {
  const fixMap = JSON.parse(await readFile(options.fixMapPath, 'utf8'));
  if (!fixMap || typeof fixMap !== 'object' || Array.isArray(fixMap)) {
    throw new Error('Fix map must be a JSON object of exact failed LaTeX to replacement LaTeX');
  }

  const fixes = [];
  const changedFiles = new Map();
  for (const failure of failures) {
    const replacement = fixMap[failure.latex];
    if (typeof replacement !== 'string' || !failure.source) continue;
    const sourcePath = resolve(workspaceRoot, failure.source);
    const original = changedFiles.has(sourcePath)
      ? changedFiles.get(sourcePath)
      : await readFile(sourcePath, 'utf8');
    const result = replaceUniqueMathExpression(original, failure.latex, replacement);
    if (result.changed) {
      changedFiles.set(sourcePath, result.source);
      fixes.push({ page: failure.page, source: failure.source, from: failure.latex, to: replacement, applied: true });
    } else {
      fixes.push({ page: failure.page, source: failure.source, from: failure.latex, to: replacement, applied: false, reason: result.reason });
    }
  }

  for (const [sourcePath, content] of changedFiles) await writeFile(sourcePath, content, 'utf8');
  return fixes;
}

async function ensureLocalTempDir() {
  const tempDir = resolve(workspaceRoot, '.tmp');
  try {
    await stat(tempDir);
  } catch (error) {
    if (error.code !== 'ENOENT') throw error;
    await mkdir(tempDir, { mode: 0o1777 });
    await chmod(tempDir, 0o1777);
  }
}

async function main() {
  let options;
  try {
    options = parseArgs(process.argv.slice(2));
    if (options.help) {
      printHelp();
      return;
    }

    await ensureLocalTempDir();
    const scan = await scanPages(options);
    const fixes = options.applyFixes ? await applyFixes(scan.failures, options) : [];
    const report = {
      generatedAt: new Date().toISOString(),
      baseUrl: options.baseUrl,
      pagesScanned: scan.pages.length - scan.unscannedPages.length,
      pagesWithMath: scan.pages.length,
      failureCount: scan.failures.length,
      failures: scan.failures,
      browserErrors: scan.browserErrors,
      unscannedPages: scan.unscannedPages,
      fixes,
    };

    await mkdir(dirname(options.reportPath), { recursive: true, mode: 0o1777 });
    await writeFile(options.reportPath, `${JSON.stringify(report, null, 2)}\n`, 'utf8');
    console.log(`Scanned ${report.pagesScanned}/${report.pagesWithMath} pages; found ${report.failureCount} MathJax failures.`);
    console.log(`Report: ${relative(workspaceRoot, options.reportPath).split(sep).join('/')}`);
    if (fixes.some((fix) => fix.applied)) {
      console.log(`Applied ${fixes.filter((fix) => fix.applied).length} explicit source fixes; rebuild and rescan to verify.`);
    }
    if (scan.failures.length || scan.unscannedPages.length) process.exitCode = 1;
  } catch (error) {
    console.error(error.message);
    process.exitCode = 1;
  }
}

if (process.argv[1] && resolve(process.argv[1]) === fileURLToPath(import.meta.url)) {
  await main();
}