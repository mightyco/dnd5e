# D&D 2024 Combat Simulator

A robust, table-driven simulation engine for Dungeons & Dragons (2024 Ruleset) built in Ruby. This project uses scientific simulation to analyze class balance, party composition, and the mathematical trade-offs of various builds.

## 🎯 Current Project Goal
The engine currently supports the **Simulation Analysis Laboratory**, comparing complex archetypes like the **Champion vs. Battlemaster Fighter**. Our goal is to provide statistically significant balance data for all D&D 2024 class compositions through at least Level 5.

## 🚀 Key Features
*   **SRD Rules Ingestion**: Dynamic extraction of class tables and spell slots from text references.
*   **Hook-based Feature System**: A modular architecture for implementing feats (GWM, Sharpshooter) and traits (Sneak Attack, Evasion).
*   **Tactical AI**: Intelligent kiting, AOE self-preservation, and "Geek the Mage" priority targeting.
*   **Scientific Dashboard**: Detailed visualization of DPR (Damage Per Round), survival rates, and roll transparency.

## 🛠 Getting Started

1.  **Prerequisites**: Ruby 3.3.x (3.3.9+), Node.js 20+, Bundler.
2.  **Install**: `bundle install && npm install --prefix docs/portal`
3.  **Build Rules**: `bundle exec rake rules:build` (Ingests data from `srd_reference/`)
4.  **Run Tests**: `bundle exec rake test`
5.  **Run Experiments**: See the `examples/` directory (e.g., `ruby examples/example_science_class_balance.rb`).

## 📊 Scientific Visualization (Simulation Lab)

The project includes a Docusaurus-based portal for deep mechanical analysis.

1.  **Start API**: `ruby scripts/sim_server.rb` (Runs on port 4567)
2.  **Start Portal**: `npm run start --prefix docs/portal` (Runs on port 3000)
3.  **Analyze**: Open `http://localhost:3000/dnd5e/` and click **"Open Live Dashboard 📊"**.

For a guide on how to interpret these results, see the **[Simulation Lab Guide](docs/docs-generated/guides/simulation-lab.mdx)**.

## 📋 Governance
This project follows strict engineering standards. For more information, see:
- [GEMINI.md](GEMINI.md): Project overview and AI instructions.
- [STYLE_GUIDE.md](STYLE_GUIDE.md): Coding and formatting standards (10/100/17 limits).
- [DEVELOPER.md](DEVELOPER.md): Rules management and benchmarking.

## ⚖️ License
MIT License. See [LICENSE](LICENSE).
