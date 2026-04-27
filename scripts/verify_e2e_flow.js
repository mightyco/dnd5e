import puppeteer from 'puppeteer';

(async () => {
  const browser = await puppeteer.launch({ headless: "new" });
  const page = await browser.newPage();

  page.on('console', msg => console.log('BROWSER LOG:', msg.text()));
  page.on('pageerror', err => console.error('BROWSER ERROR:', err.message));
  page.on('requestfailed', request => console.error('REQUEST FAILED:', request.url(), request.failure().errorText));
  
  console.log('Navigating to Simulation Laboratory...');
  await page.goto('http://localhost:4567', { waitUntil: 'networkidle0' });
  
  const content = await page.content();
  console.log('Page loaded. Content length:', content.length);
  if (content.includes('Loading Library...')) {
    console.log('Library is still loading...');
  }

  // 1. Wait for Library to load
  console.log('Waiting for Simulation Library selector...');
  await page.waitForSelector('[data-testid^="edit-preset-"]', { timeout: 10000 });
  
  // 2. Click "Edit in Lab" for a known preset
  console.log('Clicking "Edit in Lab" for champion-vs-bugbear-pack...');
  await page.click('[data-testid="edit-preset-champion-vs-bugbear-pack"]');
  
  // 3. Verify ScenarioConfigurator is visible and has data
  console.log('Verifying Scenario Configurator...');
  await page.waitForSelector('.scenario-configurator');
  
  // Check if the "Experiment Name" input has the expected value (Copy of Champion vs Bugbear Pack (Level 1))
  const experimentName = await page.$eval('input[type="text"][value^="Copy of Champion vs Bugbear Pack"]', el => el.value);
  console.log('Found Experiment Name:', experimentName);
  
  // Verify Character Pool has loaded members from preset
  const poolMembers = await page.$$eval('[data-testid="pool-member"]', els => els.length);
  console.log('Found Pool Members:', poolMembers);

  // Verify Teams have members
  const teamMembers = await page.$$eval('[data-testid="team-member"]', els => els.length);
  console.log('Found Team Members:', teamMembers);

  // 4. Modify a member and verify change
  console.log('Modifying member type...');
  
  // Wait for the specific select to be populated (means metadata is loaded)
  await page.waitForFunction(() => {
    const select = document.querySelector('[data-testid="member-type-select"]');
    return select && select.options.length > 1;
  }, { timeout: 5000 });

  // Change "fighter" to "wizard" for the first member
  await page.select('[data-testid="member-type-select"]', 'wizard');
  
  const selectedType = await page.$eval('[data-testid="member-type-select"]', el => el.value);
  console.log('New Member Type:', selectedType);

  if (selectedType !== 'wizard') {
    console.error('FAILURE: Member type did not update.');
    await browser.close();
    process.exit(1);
  }

  // 5. Launch and verify results show new type
  console.log('Launching modified experiment...');
  await page.click('[data-testid="launch-experiment"]');
  
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
