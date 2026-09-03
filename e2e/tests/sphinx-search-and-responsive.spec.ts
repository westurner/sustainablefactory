import { test, expect } from '@playwright/test';

test.describe('Sphinx docs search and responsive behavior', () => {
  const pages = [
    { path: '/', titlePart: /documentation/i },
    { path: '/readme.html', titlePart: /documentation/i },
    { path: '/genindex.html', titlePart: /index/i },
    { path: '/search.html', titlePart: /search/i },
  ];

  for (const p of pages) {
    test(`loads ${p.path}`, async ({ page }) => {
      await page.goto(p.path);
      await expect(page).toHaveTitle(p.titlePart);
      await expect(page.locator('body')).toBeVisible();
    });
  }

  test('search page supports query and shows results container', async ({ page }) => {
    await page.goto('/search.html');

    const queryInput = page.locator('input[name="q"]:visible').first();
    await expect(queryInput).toBeVisible();
    await queryInput.fill('sustainable');
    await queryInput.press('Enter');

    await expect(page).toHaveURL(/search\.html/);
    await expect(page.locator('body')).toContainText(/search|results/i);
  });

  test('native Sphinx search returns results for a fixture term', async ({ page }) => {
    await page.goto('/search.html?q=sustainable');

    const queryInput = page.locator('input[name="q"]:visible').first();
    await expect(queryInput).toHaveValue('sustainable');
    await expect(page.locator('#search-results li').first()).toBeVisible();
    await expect(page.locator('#search-results')).toContainText('sustainable');
  });

  test('native results show all matching snippets for a document', async ({ page }) => {
    await page.goto('/search.html?q=lignin&check_keywords=yes&area=default');

    const snippetGroups = page.locator('#search-results .search-snippets');
    await expect(snippetGroups.first()).toBeVisible();
    expect(await snippetGroups.first().locator('.context').count()).toBeGreaterThan(1);
  });

  test('search page loads native Sphinx search assets', async ({ page }) => {
    await page.goto('/search.html');

    await expect(page.locator('#native-sphinx-search')).toBeVisible();
    await expect(page.locator('script[src*="searchtools.js"]')).toHaveCount(1);
    await expect(page.locator('script[src*="searchindex.js"]')).toHaveCount(1);
    await expect(page.locator('#native-search-query')).toBeVisible();
    await expect(page.locator('#search-results')).toBeAttached();
  });

  test('enhanced search is a separate labeled mode and is disabled without backends', async ({ page }) => {
    await page.goto('/search.html');

    await expect(page.locator('#docindex-search')).toBeVisible();
    await expect(page.locator('#docindex-search-title')).toHaveText('DocIndex search');
    await expect(page.locator('script[src*="docindex-search.js"]')).toHaveCount(1);

    const queryInput = page.locator('#docindex-search-query');
    await queryInput.fill('homodyne');
    await queryInput.press('Enter');

    await expect(page.locator('#docindex-search-results')).toContainText(
      'DocIndex search is disabled.'
    );
  });

  test('enhanced search renders OxiRS and Meilisearch results separately', async ({ page }) => {
    await page.route('**/indexes/all/search', async (route) => {
      await route.fulfill({
        status: 200,
        contentType: 'application/json',
        body: JSON.stringify({
          hits: [{ title: 'Meili result', url: '/readme.html', content: 'Meilisearch content' }],
        }),
      });
    });
    await page.route('**/query', async (route) => {
      await route.fulfill({
        status: 200,
        contentType: 'application/sparql-results+json',
        body: JSON.stringify({
          results: {
            bindings: [{
              id: { value: 'oxirs-1' },
              title: { value: 'OxiRS result' },
              url: { value: '/schema.html' },
              content: { value: 'OxiRS content' },
            }],
          },
        }),
      });
    });

    await page.goto('/search.html');
    await page.evaluate(() => {
      (window as any).DOCINDEX_SEARCH_CONFIG = {
        docindex: {
          enabled: true,
          index: 'all',
          oxirs: { enabled: true, url: '/query' },
          meilisearch: { enabled: true, url: '/', search_url: '/indexes/all/search' },
        },
      };
    });
    await page.locator('#docindex-search-query').fill('homodyne');
    await page.locator('#docindex-search-query').press('Enter');

    const results = page.locator('#docindex-search-results');
    await expect(results).toContainText('DocIndex: OxiRS');
    await expect(results).toContainText('OxiRS result');
    await expect(results).toContainText('DocIndex: Meilisearch');
    await expect(results).toContainText('Meili result');
  });

  test('DocIndex query parameters populate the field safely', async ({ page }) => {
    const query = '<script>alert("x")</script>';
    await page.goto(`/search.html?docindex_q=${encodeURIComponent(query)}`);

    await expect(page.locator('#docindex-search-query')).toHaveValue(query);
    await expect(page.locator('script')).not.toContainText('alert("x")');
  });

  test('static OxiRS WASM search returns DocIndex results', async ({ page }) => {
    test.setTimeout(120_000);
    await page.goto('/search.html?docindex_q=sustainable');

    const results = page.locator('#docindex-search-results');
    await expect(page.locator('#docindex-search-query')).toHaveValue('sustainable');
    await expect(results).toContainText('DocIndex: OxiRS WASM', { timeout: 90_000 });
    await expect(results.locator('li').first()).toBeVisible();
    await expect(results.locator('li').first()).toContainText(/sustainable/i);
  });

  test('mobile viewport keeps top content reachable', async ({ page }) => {
    await page.setViewportSize({ width: 390, height: 844 });
    await page.goto('/');

    await expect(page.locator('h1').first()).toBeVisible();

    const searchBoxes = page.locator('input[name="q"]');
    await expect(searchBoxes.first()).toBeAttached();
  });

  test('keyboard tab navigation reaches search input', async ({ page }) => {
    await page.goto('/');

    for (let i = 0; i < 10; i += 1) {
      await page.keyboard.press('Tab');
    }

    const active = page.locator(':focus');
    await expect(active).toBeVisible();
  });
});
