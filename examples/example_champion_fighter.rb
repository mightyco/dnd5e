# frozen_string_literal: true

require_relative '../lib/dnd5e/builders/character_builder'
require_relative '../lib/dnd5e/core/team'
require_relative '../lib/dnd5e/core/features/improved_critical'
require_relative '../lib/dnd5e/experiments/experiment'
require_relative '../lib/dnd5e/simulation/runner'
require_relative '../lib/dnd5e/simulation/scenario_builder'
require_relative '../lib/dnd5e/simulation/silent_combat_result_handler'

# Champion vs Standard Fighter Demonstration (2024 Rules)

def create_standard_fighter(name, level)
  Dnd5e::Builders::CharacterBuilder.new(name: name)
                                   .as_fighter(level: level, abilities: { strength: 16, constitution: 14 })
                                   .build
end

def create_champion_fighter(name, level)
  Dnd5e::Builders::CharacterBuilder.new(name: name)
                                   .as_fighter(level: level, abilities: { strength: 16, constitution: 14 })
                                   .with_feature(Dnd5e::Core::Features::ImprovedCritical.new)
                                   .build
end

puts '=== Champion Fighter (2024) Simulation ==='
puts 'Improved Critical scores a critical hit on a 19 or 20.'
puts 'Heroic Inspiration is granted on every critical hit.'
puts ''

# --- Experiment 1: Win Rate Comparison (1v1) ---
puts 'Comparing Win Rates in 1v1 Mirror Match (Standard vs Champion)'
exp = Dnd5e::Experiments::Experiment.new(name: '1v1: Standard vs Champion')
exp.independent_variable(:level, values: [1, 3, 5])
exp.simulations_per_step(500)
exp.control_group do |p|
  members = [create_standard_fighter('Standard', p[:level])]
  Dnd5e::Core::Team.new(name: 'Standard', members: members)
end
exp.test_group do |p|
  members = [create_champion_fighter('Champion', p[:level])]
  Dnd5e::Core::Team.new(name: 'Champion', members: members)
end
exp.run

# --- Experiment 2: Damage Output Analysis ---
puts "\nAnalyzing Damage Output at Level 5 (10,000 rounds of combat)"

def create_damage_tracker(stats)
  tracker = Object.new
  tracker.define_singleton_method(:update) do |event, data|
    return unless event == :attack_resolved

    result = data[:result]
    stats[:total_damage] += result.damage
    stats[:num_crits] += 1 if result.is_crit
    stats[:num_hits] += 1 if result.success
  end
  tracker
end

def setup_combat(is_champion, level)
  attacker = is_champion ? create_champion_fighter('Champion', level) : create_standard_fighter('Standard', level)
  dummy_stat = Dnd5e::Core::Statblock.new(name: 'Dummy', hit_points: 1000, armor_class: 15)
  dummy = Dnd5e::Builders::CharacterBuilder.new(name: 'Dummy')
                                           .as_fighter(level: 20)
                                           .with_statblock(dummy_stat)
                                           .build

  [attacker, Dnd5e::Core::Team.new(name: 'Attacker', members: [attacker]),
   Dnd5e::Core::Team.new(name: 'Dummies', members: [dummy])]
end

def measure_damage(level, is_champion)
  stats = { total_damage: 0, num_crits: 0, num_hits: 0 }
  tracker = create_damage_tracker(stats)

  10_000.times do
    attacker, team_a, team_b = setup_combat(is_champion, level)
    combat = Dnd5e::Core::TeamCombat.new(teams: [team_a, team_b])
    combat.add_observer(tracker)
    combat.take_turn(attacker)
  end

  { avg_dmg: stats[:total_damage] / 10_000.0, crits: stats[:num_crits], hits: stats[:num_hits] }
end

standard_stats = measure_damage(5, false)
champion_stats = measure_damage(5, true)

puts 'Results for Level 5 Fighter (AC 15 target):'
puts "  Standard: Avg: #{standard_stats[:avg_dmg].round(2)} | Crits: #{standard_stats[:crits]} | " \
     "Hits: #{standard_stats[:hits]}"
puts "  Champion: Avg: #{champion_stats[:avg_dmg].round(2)} | Crits: #{champion_stats[:crits]} | " \
     "Hits: #{champion_stats[:hits]}"

diff = ((champion_stats[:avg_dmg] - standard_stats[:avg_dmg]) / standard_stats[:avg_dmg] * 100).round(2)
puts "\nChampion Damage Increase: #{diff}%"
