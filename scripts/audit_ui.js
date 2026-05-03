const puppeteer = require('puppeteer');

(async () => {
  const browser = await puppeteer.launch({ headless: "new" });
  const page = await browser.newPage();
  await page.setViewport({ width: 1280, height: 1000 });

  console.log('Navigating to Simulation Laboratory...');
  await page.goto('http://localhost:4567/');
  await new Promise(r => setTimeout(r, 2000));

  console.log('Running Preset: Champion vs Bugbear Pack...');
  const runButton = '[data-testid="run-preset-champion-vs-bugbear-pack"]';
  await page.waitForSelector(runButton);
  await page.click(runButton);

  console.log('Waiting for results and visualization...');
  await page.waitForSelector('.combat-playback-container', { timeout: 10000 });
  await new Promise(r => setTimeout(r, 2000));

  const hasTokens = await page.evaluate(() => {
    const circles = document.querySelectorAll('svg circle');
    return circles.length > 0;
  });

  if (!hasTokens) {
    console.error('FAIL: No tokens found in battle visualization SVG');
  } else {
    console.log('SUCCESS: Visualization rendered with tokens');
    await page.screenshot({ path: 'final_verification.png' });
  }

  await browser.close();
  process.exit(hasTokens ? 0 : 1);
})();
