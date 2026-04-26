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
  console.log('Clicking "Edit in Lab" for fighter-vs-goblin...');
  await page.click('[data-testid="edit-preset-fighter-vs-goblin"]');
  
  // 3. Verify ScenarioConfigurator is visible and has data
  console.log('Verifying Scenario Configurator...');
  await page.waitForSelector('.scenario-configurator');
  
  // Check if the "Experiment Name" input has the expected value (Copy of Fighter vs Goblin (Level 1))
  const experimentName = await page.$eval('input[type="text"][value^="Copy of Fighter vs Goblin"]', el => el.value);
  console.log('Found Experiment Name:', experimentName);
  
  // Verify Character Pool has loaded members from preset
  const poolMembers = await page.$$eval('[data-testid="pool-member"]', els => els.length);
  console.log('Found Pool Members:', poolMembers);

  // Verify Teams have members
  const teamMembers = await page.$$eval('[data-testid="team-member"]', els => els.length);
  console.log('Found Team Members:', teamMembers);

  if (experimentName.includes('Fighter vs Goblin') && poolMembers >= 2 && teamMembers >= 2) {
    console.log('SUCCESS: Edit in Lab flow verified with full data loading.');
    await browser.close();
    process.exit(0);
  } else {
    console.error('FAILURE: Data not fully loaded in configurator.', { experimentName, poolMembers, teamMembers });
    await browser.close();
    process.exit(1);
  }
})().catch(err => {
  console.error('E2E ERROR:', err);
  process.exit(1);
});
