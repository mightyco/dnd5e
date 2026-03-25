# frozen_string_literal: true

require_relative '../lib/dnd5e/builders/character_builder'
require_relative '../lib/dnd5e/core/team'
require_relative '../lib/dnd5e/core/features/improved_critical'
require_relative '../lib/dnd5e/core/features/battle_master'
require_relative '../lib/dnd5e/core/strategies/battle_master_strategy'
require_relative '../lib/dnd5e/core/team_combat'
require_relative '../lib/dnd5e/simulation/silent_combat_result_handler'

# Champion vs Battle Master Simulation (2024 Rules)
# Comparing across an adventuring day with short rests.

def create_champion(name, level)
  Dnd5e::Builders::CharacterBuilder.new(name: name)
                                   .as_fighter(level: level, abilities: { strength: 16, constitution: 14 })
                                   .with_feature(Dnd5e::Core::Features::ImprovedCritical.new)
                                   .build
end

def create_battlemaster(name, level, strategy)
  Dnd5e::Builders::CharacterBuilder.new(name: name)
                                   .as_fighter(level: level, abilities: { strength: 16, constitution: 14 })
                                   .with_feature(Dnd5e::Core::Features::BattleMaster.new(level: level))
                                   .build.tap { |f| f.strategy = strategy }
end

def create_dummy(armor_class)
  dummy_stat = Dnd5e::Core::Statblock.new(name: 'Dummy', hit_points: 10_000, armor_class: armor_class)
  Dnd5e::Builders::CharacterBuilder.new(name: 'Dummy')
                                   .as_fighter(level: 20)
                                   .with_statblock(dummy_stat)
                                   .build
end

def create_damage_tracker(stats)
  tracker = Object.new
  tracker.define_singleton_method(:update) do |event, data|
    return unless event == :attack_resolved

    result = data[:result]
    stats[:damage] += result.damage
    stats[:crits] += 1 if result.is_crit
    stats[:attacks] += 1
  end
  tracker
end

def run_day(fighter, **params)
  stats = { damage: 0, crits: 0, attacks: 0 }
  tracker = create_damage_tracker(stats)

  params[:encounters].times do |i|
    fighter.statblock.resources.reset! if params[:short_rests].include?(i)
    run_encounter(fighter, tracker, params)
  end
  stats
end

def run_encounter(fighter, tracker, params)
  dummy = create_dummy(params[:target_ac])
  combat = Dnd5e::Core::TeamCombat.new(teams: [
                                         Dnd5e::Core::Team.new(name: 'Fighter', members: [fighter]),
                                         Dnd5e::Core::Team.new(name: 'Dummies', members: [dummy])
                                       ])
  combat.add_observer(tracker)

  params[:rounds].times do
    fighter.start_turn
    combat.take_turn(fighter)
  end
end

LEVEL = 3
TARGET_AC = 15
DAYS_TO_SIMULATE = 100
ENCOUNTERS = 3
ROUNDS = 4
SHORT_REST_SCENARIOS = {
  0 => [],
  1 => [1],
  2 => [1, 2]
}.freeze

puts "=== Battle Master vs Champion Simulation (Level #{LEVEL}) ==="
puts "Adventuring Day: #{ENCOUNTERS} encounters, #{ROUNDS} rounds each"
puts "Target AC: #{TARGET_AC}"
puts "Simulating #{DAYS_TO_SIMULATE} days per scenario..."
puts ''

def run_simulations(days, level, params)
  results = {
    champion: { damage: 0, crits: 0, attacks: 0 },
    bm_damage: { damage: 0, crits: 0, attacks: 0 },
    bm_precision: { damage: 0, crits: 0, attacks: 0 }
  }

  days.times do
    update_results(results, level, params)
  end
  results
end

def update_results(results, level, params)
  champ = create_champion('Champ', level)
  add_stats(results[:champion], run_day(champ, **params))

  bm_dmg_strat = Dnd5e::Core::Strategies::BattleMasterStrategy.new(use_precision_attack: false,
                                                                   use_damage_maneuver: true)
  bm_dmg = create_battlemaster('BM-Damage', level, bm_dmg_strat)
  add_stats(results[:bm_damage], run_day(bm_dmg, **params))

  bm_prec_strat = Dnd5e::Core::Strategies::BattleMasterStrategy.new(use_precision_attack: true,
                                                                    use_damage_maneuver: false)
  bm_prec = create_battlemaster('BM-Precision', level, bm_prec_strat)
  add_stats(results[:bm_precision], run_day(bm_prec, **params))
end

def add_stats(target, source)
  target[:damage] += source[:damage]
  target[:crits] += source[:crits]
  target[:attacks] += source[:attacks]
end

def print_results(type, res, days)
  avg = calculate_averages(res, days)
  puts "#{type.to_s.upcase.ljust(15)}: Avg Damage/Day: #{avg[:dmg].to_s.ljust(8)} | " \
       "Crits: #{avg[:crits].to_s.ljust(5)} | Attacks: #{avg[:attacks]}"
end

def calculate_averages(res, days)
  {
    dmg: (res[:damage].to_f / days).round(2),
    crits: (res[:crits].to_f / days).round(2),
    attacks: (res[:attacks].to_f / days).round(1)
  }
end

SHORT_REST_SCENARIOS.each do |num_rests, rests_array|
  puts "\n--- Scenario: #{num_rests} Short Rest(s) ---"
  sim_params = { encounters: ENCOUNTERS, rounds: ROUNDS, short_rests: rests_array, target_ac: TARGET_AC }
  results = run_simulations(DAYS_TO_SIMULATE, LEVEL, sim_params)

  print_results(:champion, results[:champion], DAYS_TO_SIMULATE)
  print_results(:bm_damage, results[:bm_damage], DAYS_TO_SIMULATE)
  print_results(:bm_precision, results[:bm_precision], DAYS_TO_SIMULATE)

  puts ''
  puts 'Findings:'
  bm_lead = (results[:bm_damage][:damage] - results[:champion][:damage]).to_f / results[:champion][:damage] * 100
  puts "Battle Master (Damage) lead: #{bm_lead.round(1)}%"

  prec_lead = (results[:bm_precision][:damage] - results[:champion][:damage]).to_f / results[:champion][:damage] * 100
  puts "Battle Master (Precision) lead: #{prec_lead.round(1)}%"

  champ_dmg = results[:champion][:damage] / results[:champion][:attacks]
  catchup = (results[:bm_damage][:damage] - results[:champion][:damage]).to_f / champ_dmg
  puts "Champion needs approx. #{(catchup / (ENCOUNTERS * ROUNDS)).round(1)}x longer days to catch up."
end
