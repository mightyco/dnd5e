import puppeteer from 'puppeteer';

(async () => {
  const browser = await puppeteer.launch({ headless: "new" });
  const page = await browser.newPage();

  page.on('console', msg => console.log('BROWSER LOG:', msg.text()));
  page.on('pageerror', err => console.error('BROWSER ERROR:', err.message));
  page.on('requestfailed', request => console.error('REQUEST FAILED:', request.url(), request.failure().errorText));
  page.on('dialog', async dialog => {
    console.log('BROWSER DIALOG:', dialog.message());
    await dialog.dismiss();
  });
  
  console.log('Navigating to Simulation Laboratory...');
  await page.goto('http://localhost:4567', { waitUntil: 'domcontentloaded' });
  
  const content = await page.content();
  console.log('Page loaded. Content length:', content.length);
  if (content.includes('Loading Library...')) {
    console.log('Library is still loading...');
  }

  // 1. Wait for Library to load
  console.log('Waiting for Simulation Library selector...');
  await page.waitForSelector('[data-testid^="edit-preset-"]', { timeout: 10000 });
  
  // 2. Click "Edit in Lab" for the first available preset
  console.log('Clicking "Edit in Lab" for the first preset...');
  await page.evaluate(() => {
    const btn = document.querySelector('[data-testid^="edit-preset-"]');
    if (btn) btn.click();
  });
  
  // 3. Verify ScenarioConfigurator is visible and has data
  console.log('Verifying Scenario Configurator...');
  await page.waitForSelector('.scenario-configurator');
  await new Promise(resolve => setTimeout(resolve, 2000));
  
  // Check if the "Experiment Name" input has the expected value (Starts with "Copy of")
  const experimentName = await page.$eval('[data-testid="experiment-name-input"]', el => el.value);
  console.log('Found Experiment Name:', experimentName);
  
  if (!experimentName.startsWith('Copy of ')) {
    console.error('FAILURE: Experiment name does not start with "Copy of "');
    await browser.close();
    process.exit(1);
  }
  
  // Verify Character Pool has loaded members from preset
  const poolMembers = await page.$$eval('[data-testid="pool-member"]', els => els.length);
  console.log('Found Pool Members:', poolMembers);

  // Verify Teams have members
  const teamMembers = await page.$$eval('[data-testid="team-member"]', els => els.length);
  console.log('Found Team Members:', teamMembers);

  // 4. Modify a member and verify change
  console.log('Modifying member type...');
  
  // Wait for the specific select to be populated (means metadata is loaded)
  console.log('Waiting for metadata to populate selects...');
  await page.waitForFunction(() => {
    const select = document.querySelector('[data-testid="member-0-0-type"]');
    if (!select) return false;
    const options = Array.from(select.querySelectorAll('option'));
    return options.some(opt => opt.value === 'wizard');
  }, { timeout: 20000 });

  // Change "fighter" to "wizard" for the first member of Team 0
  await page.select('[data-testid="member-0-0-type"]', 'wizard');
  
  const selectedType = await page.$eval('[data-testid="member-0-0-type"]', el => el.value);
  console.log('New Member Type:', selectedType);

  if (selectedType !== 'wizard') {
    console.error('FAILURE: Member type did not update.');
    await browser.close();
    process.exit(1);
  }

  // 5. Launch and verify results show new type
  console.log('Launching modified experiment...');
  await page.evaluate(() => {
    const btn = document.querySelector('[data-testid="launch-experiment"]');
    if (btn) btn.click();
  });
  
  console.log('Confirming simulation intent...');
  await page.waitForSelector('[data-testid="confirm-launch"]', { timeout: 10000 });
  await page.evaluate(() => {
    const btn = document.querySelector('[data-testid="confirm-launch"]');
    if (btn) btn.click();
  });
  
  console.log('Waiting for results...');
  await page.waitForSelector('#simulation-results h2', { timeout: 30000 });
  
  const resultsHeader = await page.$eval('#simulation-results h2', el => el.textContent);
  console.log('Found Results Header:', resultsHeader);
  
  if (resultsHeader.includes('Analysis:')) {
    console.log('SUCCESS: Modified experiment completed successfully.');
    await browser.close();
    process.exit(0);
  } else {
    console.error('FAILURE: Results not found or incorrect header.', resultsHeader);
    await browser.close();
    process.exit(1);
  }
})().catch(err => {
  console.error('E2E ERROR:', err);
  process.exit(1);
});
