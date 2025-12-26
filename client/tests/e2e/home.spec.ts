import { test, expect } from '@playwright/test';

test.describe('HomePage', () => {
  test('should display the title', async ({ page }) => {
    await page.goto('/');
    await expect(page.locator('h1')).toContainText('MERN Template');
  });

  test('should have three buttons', async ({ page }) => {
    await page.goto('/');
    const buttons = page.locator('button');
    await expect(buttons).toHaveCount(3);
  });

  test('should be responsive', async ({ page }) => {
    await page.setViewportSize({ width: 375, height: 667 });
    await page.goto('/');
    await expect(page.locator('h1')).toBeVisible();
  });
});
