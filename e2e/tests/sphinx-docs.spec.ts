import { test, expect } from '@playwright/test';

test.describe('Sphinx Docs - index.html', () => {
  test('page loads with correct title', async ({ page }) => {
    await page.goto('/');
    await expect(page).toHaveTitle(/Sustainable Factory.*documentation/i);
  });

  test('main heading is visible', async ({ page }) => {
    await page.goto('/');
    await expect(page.locator('h1').first()).toBeVisible();
  });

  test('sidebar is visible', async ({ page }) => {
    await page.goto('/');
    const sidebar = page.locator('#sidebar-wrapper');
    await expect(sidebar).toBeVisible();
  });

  test('sidebar Table of Contents links navigate to anchors', async ({ page }) => {
    await page.goto('/');

    const sidebar = page.locator('#sidebar-wrapper');

    // Click "Sustainable Factory Project" anchor
    const sfpLink = sidebar.locator('a[href="#sustainable-factory-project"]');
    await expect(sfpLink).toBeVisible();
    await sfpLink.click();
    await expect(page).toHaveURL(/#sustainable-factory-project$/);

    // Click "Appendices" anchor
    await page.goto('/');
    const appendicesLink = sidebar.locator('a[href="#appendices"]');
    await expect(appendicesLink).toBeVisible();
    await appendicesLink.click();
    await expect(page).toHaveURL(/#appendices$/);

    // Click "sustainablefactory Software" anchor
    await page.goto('/');
    const softwareLink = sidebar.locator('a[href="#sustainablefactory-software"]');
    await expect(softwareLink).toBeVisible();
    await softwareLink.click();
    await expect(page).toHaveURL(/#sustainablefactory-software$/);
  });

  test('sidebar "Next topic" link navigates to readme.html', async ({ page }) => {
    await page.goto('/');
    const nextLink = page.locator('#sidebar-wrapper a[href="readme.html"]');
    await expect(nextLink).toBeVisible();
    await nextLink.click();
    await expect(page).toHaveURL(/readme\.html$/);
    await expect(page.locator('h1').first()).toBeVisible();
  });

  test('top navbar "next" link navigates to readme.html', async ({ page }) => {
    await page.goto('/');
    const nextLink = page.locator('#navbar-top a[href="readme.html"]');
    await expect(nextLink).toBeVisible();
    await nextLink.click();
    await expect(page).toHaveURL(/readme\.html$/);
  });

  test('top navbar "index" link navigates to genindex.html', async ({ page }) => {
    await page.goto('/');
    const indexLink = page.locator('#navbar-top a[href="genindex.html"]');
    await expect(indexLink).toBeVisible();
    await indexLink.click();
    await expect(page).toHaveURL(/genindex\.html$/);
    await expect(page.locator('h1').first()).toBeVisible();
  });

  test('search form is present and functional', async ({ page }) => {
    await page.goto('/');
    const searchBox = page.locator('#searchbox input[name="q"]');
    await expect(searchBox).toBeVisible();
    await searchBox.fill('process');
    await searchBox.press('Enter');
    await expect(page).toHaveURL(/search\.html/);
  });
});

test.describe('Sphinx Docs - General Index (genindex.html)', () => {
  test('index link is present on index.html and navigates to genindex.html', async ({ page }) => {
    await page.goto('/');
    // sidebar index link
    const sidebarIndexLink = page.locator('a[href="genindex.html"]').first();
    await expect(sidebarIndexLink).toBeVisible();
    await sidebarIndexLink.click();
    await expect(page).toHaveURL(/genindex\.html$/);
  });

  test('genindex.html loads with Index heading', async ({ page }) => {
    await page.goto('/genindex.html');
    await expect(page).toHaveTitle(/Index.*documentation/i);
    await expect(page.locator('h1#index')).toBeVisible();
    await expect(page.locator('h1#index')).toHaveText('Index');
  });

  test('genindex jumpbox alphabet links are present', async ({ page }) => {
    await page.goto('/genindex.html');
    const jumpbox = page.locator('.genindex-jumpbox');
    await expect(jumpbox).toBeVisible();
    await expect(jumpbox.locator('a[href="#C"]')).toBeVisible();
    await expect(jumpbox.locator('a[href="#R"]')).toBeVisible();
  });

  test('genindex jumpbox letters scroll to section headings', async ({ page }) => {
    await page.goto('/genindex.html');
    await page.locator('.genindex-jumpbox a[href="#C"]').click();
    await expect(page).toHaveURL(/#C$/);
    await expect(page.locator('h2#C')).toBeVisible();

    await page.locator('.genindex-jumpbox a[href="#R"]').click();
    await expect(page).toHaveURL(/#R$/);
    await expect(page.locator('h2#R')).toBeVisible();
  });

  test('genindex entries link to their target pages', async ({ page }) => {
    await page.goto('/genindex.html');

    // "Chats" entry → chats/index.html
    const chatsEntry = page.locator('.genindextable a[href="chats/index.html#index-0"]');
    await expect(chatsEntry).toBeVisible();
    await expect(chatsEntry).toHaveText('Chats');
    await chatsEntry.click();
    await expect(page).toHaveURL(/chats\/index\.html/);

    // "readme" entry → readme.html
    await page.goto('/genindex.html');
    const readmeEntry = page.locator('.genindextable a[href="readme.html#index-0"]');
    await expect(readmeEntry).toBeVisible();
    await expect(readmeEntry).toHaveText('readme');
    await readmeEntry.click();
    await expect(page).toHaveURL(/readme\.html/);
  });
});
