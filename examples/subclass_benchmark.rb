# frozen_string_literal: true

require_relative '../lib/dnd5e/simulation/runner'
require_relative '../lib/dnd5e/simulation/scenario'
require_relative '../lib/dnd5e/core/team'
require_relative '../lib/dnd5e/builders/character_builder'
require_relative '../lib/dnd5e/builders/monster_builder'
require_relative '../lib/dnd5e/simulation/json_combat_result_handler'

# SPEC-0010: Subclass Benchmarking CLI
# This script runs a battery of tests for each subclass against different encounter types.

SUBCLASSES = [
  { method: :as_fighter, subclass: :champion },
  { method: :as_fighter, subclass: :battlemaster },
  { method: :as_rogue, subclass: :assassin },
  { method: :as_barbarian, subclass: :berserker },
  { method: :as_paladin, subclass: :devotion },
  { method: :as_monk, subclass: nil },
  { method: :as_ranger, subclass: :hunter },
  { method: :as_cleric, subclass: :life },
  { method: :as_bard, subclass: :valor },
  { method: :as_druid, subclass: :moon },
  { method: :as_sorcerer, subclass: :draconic },
  { method: :as_warlock, subclass: :fiend }
].freeze

ENCOUNTERS = [
  { name: 'Duel (vs 1 Bugbear)', monsters: 1, type: :bugbear },
  { name: 'Pack (vs 3 Bugbears)', monsters: 3, type: :bugbear },
  { name: 'Swarm (vs 12 Goblins)', monsters: 12, type: :goblin }
].freeze

# rubocop:disable Metrics/AbcSize, Metrics/MethodLength
def run_benchmark(subclass_info, encounter)
  builder = Dnd5e::Builders::CharacterBuilder.new(name: 'Hero')
  if subclass_info[:subclass]
    builder.send(subclass_info[:method], level: 5, subclass: subclass_info[:subclass])
  else
    builder.send(subclass_info[:method], level: 5)
  end
  hero = builder.build

  monster_builder = Dnd5e::Builders::MonsterBuilder.new(name: 'Enemy')
  monsters = encounter[:monsters].times.map do |i|
    m = monster_builder.send("as_#{encounter[:type]}").build
    m.instance_variable_set(:@name, "Enemy #{i + 1}")
    m
  end

  teams = [
    Dnd5e::Core::Team.new(name: 'Heroes', members: [hero]),
    Dnd5e::Core::Team.new(name: 'Monsters', members: monsters)
  ]

  scenario = Dnd5e::Simulation::Scenario.new(teams: teams, num_simulations: 50)
  handler = Dnd5e::Simulation::JSONCombatResultHandler.new
  runner = Dnd5e::Simulation::Runner.new(scenario: scenario, result_handler: handler)
  runner.run

  combats = JSON.parse(handler.to_json)
  win_rate = combats.count { |c| c['winner'] == 'Heroes' }.to_f / combats.length * 100
  avg_rounds = combats.sum { |c| c['rounds'].length }.to_f / combats.length

  { win_rate: win_rate, avg_rounds: avg_rounds }
end
# rubocop:enable Metrics/AbcSize, Metrics/MethodLength

puts 'D&D 2024 Subclass Benchmark'
puts '==========================='
puts "Running 50 simulations per combination...\n"

# rubocop:disable Style/FormatStringToken
printf "%-20s | %-20s | %-10s | %-10s\n", 'Subclass', 'Encounter', 'Win Rate', 'Avg Rounds'
puts '-' * 70

SUBCLASSES.each do |sc|
  name = "#{sc[:method].to_s.sub('as_', '').capitalize} (#{sc[:subclass] || 'None'})"
  ENCOUNTERS.each do |enc|
    res = run_benchmark(sc, enc)
    printf "%-20s | %-20s | %8.1f%% | %10.1f\n", name, enc[:name], res[:win_rate], res[:avg_rounds]
  end
  puts '-' * 70
end
# rubocop:enable Style/FormatStringToken
