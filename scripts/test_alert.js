import puppeteer from 'puppeteer';
(async () => {
  const browser = await puppeteer.launch({ headless: "new" });
  const page = await browser.newPage();
  page.on('dialog', async dialog => {
    console.log('DIALOG DETECTED:', dialog.message());
    await dialog.dismiss();
  });
  await page.goto('http://localhost:4567', { waitUntil: 'networkidle0' });
  await page.waitForSelector('[data-testid^="edit-preset-"]');
  console.log('Clicking edit preset...');
  await page.click('[data-testid="edit-preset-fighter-vs-goblin"]');
  await new Promise(r => setTimeout(r, 1000));
  await browser.close();
})();
