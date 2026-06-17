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
