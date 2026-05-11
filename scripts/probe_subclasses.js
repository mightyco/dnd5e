import puppeteer from 'puppeteer';

(async () => {
  const browser = await puppeteer.launch({ headless: "new" });
  const page = await browser.newPage();
  
  console.log('--- SUBCLASS COUNT PROBE START ---');
  await page.goto('http://localhost:4567', { waitUntil: 'domcontentloaded' });
  
  // 1. Enter Custom Lab
  await page.evaluate(() => {
    const tabs = Array.from(document.querySelectorAll('div'));
    const customTab = tabs.find(t => t.textContent === 'Custom Lab');
    if (customTab) customTab.click();
  });
  await new Promise(resolve => setTimeout(resolve, 1000));

  // 2. Select Monk
  await page.select('[data-testid="char-builder-type"]', 'monk');
  await new Promise(resolve => setTimeout(resolve, 500));

  // 3. Count subclasses in dropdown
  const subclassData = await page.evaluate(() => {
    const select = document.querySelector('[data-testid="char-builder-subclass"]');
    if (!select) return { count: 0, items: [] };
    const options = Array.from(select.querySelectorAll('option'))
                          .filter(o => o.value !== "");
    return {
      count: options.length,
      items: options.map(o => o.value)
    };
  });

  console.log('MONK SUBCLASSES:', JSON.stringify(subclassData, null, 2));

  // 4. Select Druid
  await page.select('[data-testid="char-builder-type"]', 'druid');
  await new Promise(resolve => setTimeout(resolve, 500));
  
  const druidData = await page.evaluate(() => {
    const select = document.querySelector('[data-testid="char-builder-subclass"]');
    if (!select) return { count: 0, items: [] };
    const options = Array.from(select.querySelectorAll('option'))
                          .filter(o => o.value !== "");
    return {
      count: options.length,
      items: options.map(o => o.value)
    };
  });

  console.log('DRUID SUBCLASSES:', JSON.stringify(druidData, null, 2));

  await browser.close();
  
  if (subclassData.count < 3 || druidData.count < 3) {
    console.error('PROBE FAILED: Missing subclasses in UI dropdown.');
    process.exit(1);
  } else {
    console.log('PROBE SUCCESS: All subclasses visible.');
    process.exit(0);
  }
})().catch(err => {
  console.error('PROBE ERROR:', err);
  process.exit(1);
});
