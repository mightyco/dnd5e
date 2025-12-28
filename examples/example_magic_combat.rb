# frozen_string_literal: true

require_relative '../lib/dnd5e/core/combat'
require_relative '../lib/dnd5e/core/team_combat'
require_relative '../lib/dnd5e/core/team'
require_relative '../lib/dnd5e/core/character'
require_relative '../lib/dnd5e/core/statblock'
require_relative '../lib/dnd5e/core/attack'
require_relative '../lib/dnd5e/core/dice'
require_relative '../lib/dnd5e/core/dice_roller'
require_relative '../lib/dnd5e/core/combat_logger'
require 'logger'

puts '=== Magic Combat Example ==='

# Setup Wizard
wizard_statblock = Dnd5e::Core::Statblock.new(
  name: 'Wizard',
  intelligence: 16, # +3 Mod
  dexterity: 14,
  level: 5, # Prof +3
  saving_throw_proficiencies: %i[intelligence wisdom]
)
# Wizard DC: 8 + 3 (Prof) + 3 (Int) = 14

fireball = Dnd5e::Core::Attack.new(
  name: 'Fireball',
  damage_dice: Dnd5e::Core::Dice.new(8, 6),
  type: :save,
  save_ability: :dexterity,
  dc_stat: :intelligence,
  half_damage_on_save: true
)

wizard = Dnd5e::Core::Character.new(name: 'Wizard', statblock: wizard_statblock, attacks: [fireball])

# Setup Goblin
goblin_statblock = Dnd5e::Core::Statblock.new(
  name: 'Goblin',
  dexterity: 14, # +2 Mod. Save Mod +2 (not proficient)
  hit_die: 'd6',
  level: 1
)
# Goblin Dex Save: d20 + 2 vs DC 14. Needs 12+ to save.

goblin_attack = Dnd5e::Core::Attack.new(
  name: 'Scimitar',
  damage_dice: Dnd5e::Core::Dice.new(1, 6),
  relevant_stat: :dexterity
)

goblin = Dnd5e::Core::Character.new(name: 'Goblin', statblock: goblin_statblock, attacks: [goblin_attack])

# Setup Teams
team_heroes = Dnd5e::Core::Team.new(name: 'Heroes', members: [wizard])
team_monsters = Dnd5e::Core::Team.new(name: 'Monsters', members: [goblin])

# Setup Combat
combat = Dnd5e::Core::TeamCombat.new(teams: [team_heroes, team_monsters])
# Default logger with timestamps is desired
combat.add_observer(Dnd5e::Core::CombatLogger.new)

puts 'Starting battle: Wizard vs Goblin'
combat.run_combat
