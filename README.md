# D&D 2024 Combat Simulator

A robust, table-driven simulation engine for Dungeons & Dragons (2024 Ruleset) built in Ruby. This project uses scientific simulation to analyze class balance, party composition, and the mathematical trade-offs of various builds.

## 🎯 Current Project Goal
We are currently modeling the **Champion vs. Battlemaster Fighter** comparison to determine how the 2024 rules change the classic "consistent vs. burst" debate. Our ultimate goal is to verify balance across all class compositions through at least Level 5.

## 🚀 Key Features
*   **SRD Rules Ingestion**: Dynamic extraction of class tables and spell slots from text references.
*   **Hook-based Feature System**: A modular architecture for implementing feats (GWM, Sharpshooter) and traits (Sneak Attack, Evasion).
*   **Tactical AI**: Intelligent kiting, AOE self-preservation, and "Geek the Mage" priority targeting.
*   **Math Transparency**: Every roll is logged with full metadata (e.g., `Attacker rolled 18 (Adv: [15, 12] -> 15 + 3)`).

## 🛠 Getting Started

1.  **Prerequisites**: Ruby 3.3.x, Bundler.
2.  **Install**: `bundle install`
3.  **Build Rules**: `bundle exec rake rules:build` (Ingests data from `srd_reference/`)
4.  **Run Tests**: `bundle exec rake test`
5.  **Run Experiments**: See the `examples/` directory (e.g., `ruby examples/example_science_class_balance.rb`).

## 📈 Roadmap
For detailed technical progress and historical findings, see [ROADMAP.md](ROADMAP.md).

## ⚖️ License
MIT License. See [LICENSE.md](LICENSE.md).
