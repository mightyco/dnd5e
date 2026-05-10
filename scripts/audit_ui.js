import puppeteer from 'puppeteer';

/**
 * UI INTERACTION AUDIT SCRIPT
 * 
 * This script runs a custom simulation and then audits the results view
 * for overlapping elements, layout issues, and interaction bugs.
 */

(async () => {
  const browser = await puppeteer.launch({ headless: "new" });
  const page = await browser.newPage();

  const logs = [];
  const errors = [];

  page.on('console', msg => logs.push(`[${msg.type()}] ${msg.text()}`));
  page.on('pageerror', err => errors.push(err.message));
  
  console.log('Navigating to Simulation Laboratory...');
  await page.goto('http://localhost:4567', { waitUntil: 'domcontentloaded' });
  
  // 1. Enter Custom Lab
  console.log('Switching to Custom Lab...');
  await page.waitForSelector('.simulation-dashboard');
  await page.evaluate(() => {
    const tabs = Array.from(document.querySelectorAll('div'));
    const customTab = tabs.find(t => t.textContent === 'Custom Lab');
    if (customTab) customTab.click();
  });

  // 2. Build a custom character
  console.log('Building custom character...');
  await page.waitForSelector('[data-testid="char-builder-name"]');
  await page.click('[data-testid="char-builder-name"]', { clickCount: 3 });
  await page.keyboard.press('Backspace');
  await page.type('[data-testid="char-builder-name"]', 'Audit Hero');
  await page.click('[data-testid="save-to-pool-btn"]');

  // 3. Assign to team
  console.log('Assigning to Team A...');
  await page.waitForSelector('[data-testid="add-to-team-0-Audit Hero"]');
  await page.click('[data-testid="add-to-team-0-Audit Hero"]');

  // 4. Launch Experiment
  console.log('Launching experiment...');
  await page.click('[data-testid="launch-experiment"]');
  
  // 5. Confirm Manifest
  console.log('Confirming manifest...');
  await page.waitForSelector('[data-testid="confirm-launch"]');
  await page.click('[data-testid="confirm-launch"]');

  // 6. Wait for results
  console.log('Waiting for results...');
  await page.waitForSelector('#simulation-results', { timeout: 30000 });
  await new Promise(resolve => setTimeout(resolve, 5000)); // Wait for charts to settle

  // 7. Audit Overlaps
  console.log('Auditing element overlaps...');
  const overlaps = await page.evaluate(() => {
    const results = [];
    const elements = Array.from(document.querySelectorAll('#simulation-results > div, #simulation-results div > div'));
    
    for (let i = 0; i < elements.length; i++) {
      for (let j = i + 1; j < elements.length; j++) {
        const rect1 = elements[i].getBoundingClientRect();
        const rect2 = elements[j].getBoundingClientRect();
        
        // Skip zero-size or hidden elements
        if (rect1.width === 0 || rect1.height === 0 || rect2.width === 0 || rect2.height === 0) continue;
        
        // Check if one element completely contains another (usually fine)
        const contains = (r1, r2) => (
          r1.left <= r2.left && r1.right >= r2.right &&
          r1.top <= r2.top && r1.bottom >= r2.bottom
        );
        
        if (contains(rect1, rect2) || contains(rect2, rect1)) continue;

        // Check for partial intersection
        const overlap = !(
          rect1.right < rect2.left || 
          rect1.left > rect2.right || 
          rect1.bottom < rect2.top || 
          rect1.top > rect2.bottom
        );

        if (overlap) {
          results.push({
            el1: elements[i].tagName + (elements[i].className ? '.' + elements[i].className : ''),
            el2: elements[j].tagName + (elements[j].className ? '.' + elements[j].className : ''),
            rect1: { t: rect1.top, l: rect1.left, w: rect1.width, h: rect1.height },
            rect2: { t: rect2.top, l: rect2.left, w: rect2.width, h: rect2.height }
          });
        }
      }
    }
    return results;
  });

  console.log('--- UI AUDIT REPORT ---');
  console.log(`Browser Errors: ${errors.length}`);
  errors.forEach(e => console.log(`  ERROR: ${e}`));
  
  console.log(`Detected Overlaps: ${overlaps.length}`);
  overlaps.forEach(o => {
    console.log(`  OVERLAP: ${o.el1} and ${o.el2}`);
    console.log(`    Rect1: ${JSON.stringify(o.rect1)}`);
    console.log(`    Rect2: ${JSON.stringify(o.rect2)}`);
  });

  // 8. Capture Screenshot
  console.log('Capturing audit screenshot...');
  await page.screenshot({ path: 'audit_results.png', fullPage: true });

  await browser.close();
})().catch(err => {
  console.error('AUDIT ERROR:', err);
  process.exit(1);
});
