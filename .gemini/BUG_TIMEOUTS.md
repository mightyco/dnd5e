# BUG-001: Excessive Combat Timeouts in Swarm Simulations

## Description
Simulations involving multiple combatants (e.g., Ranger vs 2-3 Bugbears) frequently hit the 100-round timeout. Mathematically, a Level 5 Ranger with an 85%+ hit rate and 15+ DPR should finish a CR 1 Bugbear (35 HP) in ~3-4 rounds. Even against 3 Bugbears, combat should resolve within 15-20 rounds.

## Empirical Evidence
- **Ranger vs 2 Bugbears**: 30% of simulations timed out after 100 rounds.
- **Ranger vs 3 Bugbears**: 40%+ of simulations timed out.

## Potential Root Causes
1. **AI Standoff**: Both sides might be kiting/repositioning without attacking if their range/movement logic has a "dead zone."
2. **Pathfinding Deadlocks**: If the grid becomes crowded, combatants might be spending entire turns moving in circles or failing to find a path to a target, resulting in "zero-action" turns.
3. **Condition Desync**: If a condition like 'Restrained' or 'Slowed' is not being cleared correctly, it could permanently trap a combatant out of range.

## Next Steps
- Implement a 'Stall Detector' in the combat engine to log turns where no movement and no attacks occur.
- Run a spatial trace for a 100-round combat to visualize the standoff.
