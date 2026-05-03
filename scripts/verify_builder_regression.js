const puppeteer = require('puppeteer');

(async () => {
  const browser = await puppeteer.launch({ headless: "new" });
  const page = await browser.newPage();
  await page.setViewport({ width: 1280, height: 1000 });

  console.log('Navigating to Simulation Laboratory...');
  try {
    await page.goto('http://localhost:4567/');
  } catch (e) {
    console.error('FAIL: Could not connect to server. Is it running?');
    process.exit(1);
  }
  await new Promise(r => setTimeout(r, 3000));

  console.log('Opening "Champion vs Bugbear Pack" for editing...');
  const editButton = '[data-testid="edit-preset-champion-vs-bugbear-pack"]';
  await page.waitForSelector(editButton, { timeout: 5000 });
  await page.click(editButton);
  await new Promise(r => setTimeout(r, 1000));

  console.log('Checking Inline Team Member Editor for Team A...');
  // Ensure we are in the configurator
  const teamPanel = await page.$('[data-testid="team-panel-0"]');
  if (!teamPanel) {
    console.error('FAIL: Could not find team panel 0');
    process.exit(1);
  }

  const memberTypeSelect = await page.$('[data-testid="team-panel-0"] [data-testid="member-type-select"]');
  const options = await page.evaluate(el => Array.from(el.options).map(o => o.value), memberTypeSelect);
  console.log('Available classes in inline editor:', options.filter(o => !['goblin', 'bugbear', 'ogre'].includes(o)));
  
  const expectedClasses = ['fighter', 'wizard', 'rogue', 'barbarian', 'paladin', 'monk', 'ranger', 'cleric', 'bard', 'druid', 'sorcerer', 'warlock'];
  const missingClasses = expectedClasses.filter(c => !options.includes(c));

  if (missingClasses.length > 0) {
    console.error('FAIL: Inline editor missing classes:', missingClasses);
  } else {
    console.log('SUCCESS: All classes present in inline editor');
  }

  const hasAbilityInputs = await page.$$eval('[data-testid="team-panel-0"] input', inputs => 
    inputs.some(i => i.name && i.name.startsWith('ability'))
  );
  
  if (!hasAbilityInputs) {
    console.error('FAIL: Inline editor missing ability score inputs');
  } else {
    console.log('SUCCESS: Ability scores found in inline editor');
  }

  await browser.close();
  if (missingClasses.length > 0 || !hasAbilityInputs) process.exit(1);
  console.log('ALL REGRESSION CHECKS PASSED');
})();
