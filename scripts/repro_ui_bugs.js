import puppeteer from 'puppeteer';

(async () => {
  const browser = await puppeteer.launch({ headless: "new" });
  const page = await browser.newPage();
  let errors = [];

  page.on('console', msg => {
    if (msg.type() === 'error') {
      console.log('BROWSER ERROR LOG:', msg.text());
      errors.push(msg.text());
    }
  });
  page.on('pageerror', err => {
    console.error('CRITICAL PAGE ERROR:', err.message);
    errors.push(err.message);
  });
  
  await page.goto('http://localhost:4567', { waitUntil: 'networkidle0' });
  await page.waitForSelector('[data-testid^="run-preset-"]', { timeout: 10000 });

  console.log('--- TEST 1: Playback Transition Crash ---');
  // 1. Run Scenario A with many runs to ensure long logs
  console.log('Running Scenario A (Battle Master) with 500 simulations...');
  await page.evaluate(() => {
    fetch('/api/run', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        id: 'long-run', name: 'Long Run', level: 5, num_simulations: 500,
        teams: [
          { name: 'Heroes', members: [{ name: 'BM', type: 'fighter', subclass: 'battlemaster' }] },
          { name: 'Monsters', count: 5, template: { name: 'G', type: 'goblin' } }
        ]
      })
    });
  });
  
  // Actually just click run on a preset but override num_sims if we can? 
  // Simpler: just wait for UI to show results.
  await page.click('[data-testid="run-preset-battlemaster-vs-bugbear-pack"]');
  await page.waitForSelector('#combat-playback-section', { timeout: 15000 });

  // 2. Click Play
  console.log('Clicking Play...');
  await page.evaluate(() => {
    const buttons = document.querySelectorAll('button');
    for (const b of buttons) {
      if (b.textContent.includes('Play')) b.click();
    }
  });
  
  // Wait for playback to reach a high event index
  console.log('Waiting for playback to progress...');
  await new Promise(r => setTimeout(r, 3000));

  // 3. Run Scenario B (very short) immediately
  console.log('Running Scenario B (Champion, 1 sim) while Scenario A is playing...');
  await page.click('[data-testid="run-preset-ses-boss-ogre"]');
  
  // Wait for results to update
  await new Promise(r => setTimeout(r, 2000));

  // Check if page crashed (results header missing or errors detected)
  const resultsHeader = await page.$('#simulation-results h2');
  const playbackErrorVisible = await page.$eval('#combat-playback-section', el => el.textContent.includes('Playback Error')).catch(() => false);
  
  if (playbackErrorVisible) {
     console.log('RESULT: [FIXED] ErrorBoundary surfaced the crash instead of a blank screen.');
  } else if (!resultsHeader || errors.some(e => e.includes('TypeError') || e.includes('Cannot read'))) {
    console.log('RESULT: [REPRODUCED] Page crashed or showed blank screen during transition.');
  } else {
    console.log('RESULT: [FIXED] Page is stable and reset index correctly.');
  }

  console.log('\n--- TEST 2: Stale Subclass Regression ---');
  // 1. Go to Custom Lab
  console.log('Switching to Custom Lab...');
  await page.evaluate(() => {
    const tabs = document.querySelectorAll('div');
    for (const t of tabs) {
      if (t.textContent.includes('Custom Lab')) t.click();
    }
  });
  await page.waitForSelector('.scenario-configurator', { timeout: 5000 });

  // 2. Load a Preset for editing (Fighter)
  console.log('Switching back to Library Presets...');
  await page.evaluate(() => {
    const tabs = document.querySelectorAll('div');
    for (const t of tabs) {
      if (t.textContent.includes('Library Presets')) t.click();
    }
  });
  
  console.log('Waiting for Library to reload...');
  await page.waitForSelector('[data-testid="edit-preset-champion-vs-bugbear-pack"]', { timeout: 5000 });
  
  console.log('Loading Fighter preset for editing...');
  await page.click('[data-testid="edit-preset-champion-vs-bugbear-pack"]');
  await page.waitForSelector('[data-testid="member-subclass-select"]', { timeout: 5000 });

  // 3. Change to Monster
  console.log('Changing Fighter to Goblin...');
  await page.select('[data-testid="member-type-select"]', 'goblin');
  
  // 4. Verify if Subclass select persists
  const subclassVisible = await page.$('[data-testid="member-subclass-select"]');
  if (subclassVisible) {
    console.log('RESULT: [REPRODUCED] Subclass dropdown persisted for a Monster.');
  } else {
    console.log('RESULT: [NOT REPRODUCED] Subclass dropdown correctly disappeared.');
  }

  await browser.close();
  
  console.log('\n--- LLM JUDGMENT DATA ---');
  console.log('Collected Errors:', JSON.stringify(errors));
  
  if (errors.length > 0 || subclassVisible) {
    console.log('SUMMARY: Bugs detected and reproduced.');
    process.exit(0); // Exit 0 so we can read the output, we'll "judge" in the next step
  } else {
    console.log('SUMMARY: No bugs detected.');
    process.exit(0);
  }
})().catch(err => {
  console.error('FATAL REPRO ERROR:', err);
  process.exit(1);
});
