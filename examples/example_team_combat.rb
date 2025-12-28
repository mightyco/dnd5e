# frozen_string_literal: true

require_relative '../lib/dnd5e/core/team_combat'
require_relative '../lib/dnd5e/core/team'
require_relative '../lib/dnd5e/core/character'
require_relative '../lib/dnd5e/core/monster'
require_relative '../lib/dnd5e/core/statblock'
require_relative '../lib/dnd5e/core/attack'
require_relative '../lib/dnd5e/core/dice'
require_relative '../lib/dnd5e/core/combat_logger'
require 'logger'

puts '=== Team Combat Example ==='

# Setup Teams
# Heroes: 2 Fighters
longsword = Dnd5e::Core::Attack.new(name: 'Longsword', damage_dice: Dnd5e::Core::Dice.new(1, 8),
                                    relevant_stat: :strength)
hero_stats = Dnd5e::Core::Statblock.new(name: 'Hero Template', strength: 16, hit_points: 20)

hero1 = Dnd5e::Core::Character.new(name: 'Fighter 1', statblock: hero_stats, attacks: [longsword])
hero2 = Dnd5e::Core::Character.new(name: 'Fighter 2', statblock: hero_stats, attacks: [longsword])
team_heroes = Dnd5e::Core::Team.new(name: 'Heroes', members: [hero1, hero2])

# Monsters: 2 Goblins
scimitar = Dnd5e::Core::Attack.new(name: 'Scimitar', damage_dice: Dnd5e::Core::Dice.new(1, 6),
                                   relevant_stat: :dexterity)
goblin_stats = Dnd5e::Core::Statblock.new(name: 'Goblin Template', dexterity: 14, hit_points: 15)

goblin1 = Dnd5e::Core::Monster.new(name: 'Goblin 1', statblock: goblin_stats, attacks: [scimitar])
goblin2 = Dnd5e::Core::Monster.new(name: 'Goblin 2', statblock: goblin_stats, attacks: [scimitar])
team_goblins = Dnd5e::Core::Team.new(name: 'Goblins', members: [goblin1, goblin2])

# Configure Combat
combat = Dnd5e::Core::TeamCombat.new(teams: [team_heroes, team_goblins])
logger = Logger.new($stdout)
logger.formatter = proc { |_sev, _dt, _prog, msg| "#{msg}\n" }
combat.add_observer(Dnd5e::Core::CombatLogger.new(logger))

# Execution
puts "Starting battle: #{team_heroes.members.map(&:name).join(', ')} vs #{team_goblins.members.map(&:name).join(', ')}"
combat.run_combat
