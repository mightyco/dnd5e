import puppeteer from 'puppeteer';

/**
 * REPRODUCTION SCRIPT: UI Team Desync Bug (V3)
 */

(async () => {
  const browser = await puppeteer.launch({ headless: "new" });
  const page = await browser.newPage();

  page.on('console', msg => console.log('BROWSER LOG:', msg.text()));
  page.on('pageerror', err => console.error('BROWSER ERROR:', err.message));
  
  console.log('Navigating to Simulation Laboratory...');
  await page.goto('http://localhost:4567', { waitUntil: 'networkidle0' });
  
  // 1. Click "Edit in Lab" for a known preset
  console.log('Clicking "Edit in Lab" for battlemaster-vs-bugbear-pack...');
  await page.waitForSelector('[data-testid="edit-preset-battlemaster-vs-bugbear-pack"]');
  await page.click('[data-testid="edit-preset-battlemaster-vs-bugbear-pack"]');
  
  // 2. Use Character Builder to add a new player
  console.log('Adding a new character...');
  await page.waitForSelector('[data-testid="char-builder-name"]');
  await page.click('[data-testid="char-builder-name"]', { clickCount: 3 });
  await page.keyboard.press('Backspace');
  await page.type('[data-testid="char-builder-name"]', 'Added Hero');
  await page.click('[data-testid="save-to-pool-btn"]');
  
  // 3. Assign the new character to Team A (Index 0)
  console.log('Assigning new character to Team A...');
  await page.waitForSelector('[data-testid="add-to-team-0-Added Hero"]');
  await page.click('[data-testid="add-to-team-0-Added Hero"]');

  // 4. Launch Experiment
  console.log('Launching experiment...');
  // Intercept the request to /api/run to inspect the payload
  await page.setRequestInterception(true);
  page.on('request', interceptedRequest => {
    if (interceptedRequest.url().endsWith('/api/run') && interceptedRequest.method() === 'POST') {
      const postData = JSON.parse(interceptedRequest.postData());
      console.log('INTERCEPTED PAYLOAD:', JSON.stringify(postData, null, 2));
    }
    interceptedRequest.continue();
  });

  await page.click('[data-testid="launch-experiment"]');
  
  console.log('Waiting for results...');
  await page.waitForSelector('#simulation-results', { timeout: 30000 });

  // 5. Inspect playback snapshots
  const snapshots = await page.evaluate(() => {
    // Wait a bit for playback to initialize
    return new Promise(resolve => {
      setTimeout(() => {
        const combatants = Array.from(document.querySelectorAll('.combat-playback-container [data-team]'));
        resolve(combatants.map(c => ({
          name: c.textContent.trim(),
          team: c.getAttribute('data-team')
        })));
      }, 2000);
    });
  });

  if (snapshots && snapshots.length > 0) {
    console.log('Combatant teams in playback:', snapshots);
    const uniqueTeams = [...new Set(snapshots.map(s => s.team))];
    if (uniqueTeams.length === 1) {
      console.log('REPRODUCED: Only one team found in playback.');
      await browser.close();
      process.exit(0);
    } else {
      console.log('Unique teams found:', uniqueTeams.length);
    }
  } else {
    console.log('No combatants found in playback container.');
  }

  console.log('Finished analysis.');
  await browser.close();
  process.exit(1);
})().catch(err => {
  console.error('E2E ERROR:', err);
  process.exit(1);
});
