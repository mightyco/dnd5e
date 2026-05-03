# frozen_string_literal: true

require_relative '../lib/dnd5e/simulation/runner'
require_relative '../lib/dnd5e/simulation/scenario'
require_relative '../lib/dnd5e/core/team'
require_relative '../lib/dnd5e/builders/character_builder'
require_relative '../lib/dnd5e/builders/monster_builder'
require_relative '../lib/dnd5e/simulation/json_combat_result_handler'
require 'logger'

# SPEC-0010: Subclass Benchmarking CLI
# This script runs a battery of tests for each subclass against different encounter types.

# Dynamically build the list of subclasses to test
def discover_subclasses
  all_subclasses = []
  Dnd5e::Core::SubclassRegistry.all_by_class.each do |cls, scs|
    method = :"as_#{cls}"
    scs.each { |sc| all_subclasses << { method: method, subclass: sc } }
    all_subclasses << { method: method, subclass: nil }
  end
  all_subclasses.sort_by { |s| [s[:method], s[:subclass].to_s] }
end

SUBCLASSES = discover_subclasses

ENCOUNTERS = [
  { name: 'Duel (vs 1 Bugbear)', monsters: 1, type: :bugbear },
  { name: 'Duel (vs 2 Bugbear)', monsters: 2, type: :bugbear },
  { name: 'Swarm (vs 3 Goblins)', monsters: 3, type: :goblin },
  { name: 'Swarm (vs 6 Goblins)', monsters: 6, type: :goblin },
  { name: 'Swarm (vs 9 Goblins)', monsters: 9, type: :goblin },
  { name: 'Swarm (vs 12 Goblins)', monsters: 12, type: :goblin }
].freeze

def run_benchmark(subclass_info, encounter, runs = 100)
  teams = [
    Dnd5e::Core::Team.new(name: 'Heroes', members: [build_hero(subclass_info)]),
    Dnd5e::Core::Team.new(name: 'Monsters', members: build_monsters(encounter))
  ]

  scenario = Dnd5e::Simulation::Scenario.new(teams: teams, num_simulations: runs)
  handler = Dnd5e::Simulation::JSONCombatResultHandler.new
  logger = Logger.new('benchmark.log')
  Dnd5e::Simulation::Runner.new(scenario: scenario, result_handler: handler, logger: logger).run

  calculate_stats(JSON.parse(handler.to_json))
end

def build_hero(info)
  abilities = { strength: 18, dexterity: 18, constitution: 18, intelligence: 18, wisdom: 18, charisma: 18 }
  builder = Dnd5e::Builders::CharacterBuilder.new(name: 'Hero')
  if info[:subclass]
    builder.send(info[:method], level: 5, subclass: info[:subclass], abilities: abilities)
  else
    builder.send(info[:method], level: 5, abilities: abilities)
  end
  builder.build
end

def build_monsters(encounter)
  monster_builder = Dnd5e::Builders::MonsterBuilder.new(name: 'Enemy')
  encounter[:monsters].times.map do |i|
    m = monster_builder.send("as_#{encounter[:type]}").build
    m.instance_variable_set(:@name, "Enemy #{i + 1}")
    m
  end
end

def calculate_stats(combats)
  win_rate = (combats.count { |c| c['winner'] == 'Heroes' }.to_f / combats.length * 100).round(1)
  avg_rounds = (combats.sum { |c| c['rounds'].length }.to_f / combats.length).round(1)
  { win_rate: win_rate, avg_rounds: avg_rounds }
end

def print_header
  puts 'D&D 2024 Subclass Benchmark'
  puts '==========================='
  # rubocop:disable Style/FormatStringToken
  printf "%-22s | %-20s | %-10s | %-10s\n", 'Subclass', 'Encounter', 'Win Rate', 'Avg Rounds'
  # rubocop:enable Style/FormatStringToken
  puts '-' * 75
end

def run_all_benchmarks
  print_header
  SUBCLASSES.each do |subclass|
    name = "#{subclass[:method].to_s.sub('as_', '').capitalize} (#{subclass[:subclass] || 'None'})"
    run_encounter_suite(subclass, name)
    puts '-' * 75
  end
end

def run_encounter_suite(subclass, name)
  ENCOUNTERS.each do |enc|
    res = run_benchmark(subclass, enc)
    # rubocop:disable Style/FormatStringToken
    printf "%-22s | %-20s | %8.1f%% | %10.1f\n", name, enc[:name], res[:win_rate], res[:avg_rounds]
    # rubocop:enable Style/FormatStringToken
  end
end

run_all_benchmarks if __FILE__ == $PROGRAM_NAME
