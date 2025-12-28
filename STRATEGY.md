# D&D 5e Combat Simulation Strategy Guide

This guide summarizes the findings from our simulation engine regarding 5e combat mechanics, specifically focusing on the Strength vs. Dexterity balance.

## Key Findings

### 1. Initiative vs. Armor Class (The "Alpha Strike" Effect)
*   **Low Levels (1-4)**: Initiative is a dominant stat. In short combats (low HP), acting first often allows a combatant to land a decisive blow (or kill) before the opponent can respond.
*   **High Levels (5+)**: As HP pools grow, combat length increases (from ~2 rounds to ~10+ rounds). Initiative becomes less critical, and **Armor Class (AC)** becomes the deciding factor in attrition wars.

### 2. Strength vs. Dexterity Scaling
*   **Naked Combat**: Dexterity wins ~70% of the time due to providing both AC and Initiative. Strength is severely disadvantaged without equipment.
*   **Equipped Combat**: Strength (Heavy Armor) wins ~60% of the time against Dexterity (Light Armor) in 1v1 duels at Level 3+.
    *   **Reason**: Plate Armor (AC 18/20) provides superior mitigation compared to Studded Leather (AC 15/17), allowing Strength fighters to survive the initial Initiative disadvantage and win the long game.

### 3. Weapon Archetypes
*   **Greatsword (2d6)** vs **Shield (1d8 + 2 AC)**:
    *   **Offense Wins**: The Greatsword archetype consistently beats the Shield archetype (~55-60% win rate). The extra damage output (avg 11 vs 7.5) outweighs the +2 AC in a straight damage race.
*   **Glass Cannons**: High-damage, low-AC builds (e.g., Dex Skirmisher) lose badly (~97% loss rate) against high-AC, high-damage builds (Str Greatsword) at higher levels. Durability is a prerequisite for applying damage over time.

## Mechanics Implementation Status

- [x] **Ability Scores & Mods**: Core resolution engine.
- [x] **Attack Rolls & AC**: Functional.
- [x] **Damage & HP**: Functional.
- [x] **Saving Throws**: Implemented for spells/abilities.
- [x] **Armor & Shields**: Light, Medium, Heavy armor logic with Dex caps.
- [x] **Advantage/Disadvantage**: Implemented.
- [x] **Critical Hits**: Basic 20=Hit implemented, double damage dice verified.
- [x] **Feats**: Great Weapon Master, Sharpshooter (-5/+10 mechanic implemented).
- [ ] **Conditions**: Prone, Grappled, Restrained.
- [ ] **Skills**: Athletics, Acrobatics.

### 6. Character Progression & AI (New Priority)
To simulate complex matchups like Wizard vs. Rogue, we need:
- [x] **Action Economy**: Track Action, Bonus Action, and Reaction usage per turn.
- [x] **Strategy Engine**: Pluggable AI to decide:
    -   *Rogue*: Hide (Bonus Action) -> Attack (Action) vs. Dash/Disengage. (Implemented)
    -   *Wizard*: Cast Spell (Level?) vs. Cantrip vs. Dodge.
- [ ] **Class Features**:
    -   [x] *Rogue*: Cunning Action (Hide implemented).
    -   [ ] *Rogue*: Sneak Attack (Damage scaling), Uncanny Dodge.
    -   [ ] *Wizard*: Spell Slots, Arcane Recovery, Signature Spells.

## Future Enhancements
*   More complex character classes and abilities.
*   More detailed combat logging.
*   Support for different types of attacks and damage.
*   A command-line interface (CLI) for running simulations.
*   Provide a record and replay capability with exemplars
*   Provide the ability to rate concepts against many simulation runs
*   Provide a UI to allow others to use the concepts

## Recommendations for Optimization
If you want to win a duel in this simulator:
1.  **Wear Plate Armor**.
2.  **Use a Greatsword**.
3.  **Survive Round 1**.
