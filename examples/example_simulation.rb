# frozen_string_literal: true

require_relative '../lib/dnd5e/simulation/runner'
require_relative '../lib/dnd5e/simulation/scenario_builder'
require_relative '../lib/dnd5e/core/combat_statistics'
require_relative '../lib/dnd5e/core/attack'
require_relative '../lib/dnd5e/core/dice'
require_relative '../lib/dnd5e/core/statblock'
require_relative '../lib/dnd5e/core/character'
require_relative '../lib/dnd5e/core/monster'
require_relative '../lib/dnd5e/core/team'
require 'logger'

puts '=== Simulation Example ==='
puts 'Running 1000 simulations of Heroes vs Goblins...'

# Stats Handler (no noisy output per turn, just aggregate stats)
stats = Dnd5e::Core::CombatStatistics.new
logger = Logger.new($stdout)
logger.level = Logger::WARN # Silence individual combat logs for simulation

# Setup Scenario
hero_sword = Dnd5e::Core::Attack.new(name: 'Sword', damage_dice: Dnd5e::Core::Dice.new(1, 8), relevant_stat: :strength)
hero_stats = Dnd5e::Core::Statblock.new(name: 'Hero Template', strength: 16, hit_die: 'd10', level: 1)

goblin_bite = Dnd5e::Core::Attack.new(name: 'Bite', damage_dice: Dnd5e::Core::Dice.new(1, 6), relevant_stat: :dexterity)
goblin_stats = Dnd5e::Core::Statblock.new(name: 'Goblin Template', dexterity: 14, hit_die: 'd8', level: 1)

heroes = Dnd5e::Core::Team.new(name: 'Heroes', members: [
                                 Dnd5e::Core::Character.new(name: 'Hero 1', statblock: hero_stats,
                                                            attacks: [hero_sword]),
                                 Dnd5e::Core::Character.new(name: 'Hero 2', statblock: hero_stats,
                                                            attacks: [hero_sword])
                               ])

goblins = Dnd5e::Core::Team.new(name: 'Goblins', members: [
                                  Dnd5e::Core::Monster.new(name: 'Goblin 1', statblock: goblin_stats,
                                                           attacks: [goblin_bite]),
                                  Dnd5e::Core::Monster.new(name: 'Goblin 2', statblock: goblin_stats,
                                                           attacks: [goblin_bite])
                                ])

scenario = Dnd5e::Simulation::ScenarioBuilder.new(num_simulations: 1000)
                                             .with_team(heroes)
                                             .with_team(goblins)
                                             .build

runner = Dnd5e::Simulation::Runner.new(
  scenario: scenario,
  result_handler: stats,
  logger: logger
)

runner.run
runner.generate_report
