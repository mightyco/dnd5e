# frozen_string_literal: true

require_relative 'lib/dnd5e/simulation/runner'
require_relative 'lib/dnd5e/simulation/scenario_builder'
require_relative 'lib/dnd5e/simulation/json_combat_result_handler'
require_relative 'scripts/sim_server' # for build_scenario_from_payload

preset = JSON.parse(File.read('data/simulations/presets/fighter-duel-bm-vs-champ.json'))
preset['num_simulations'] = 1000 # Increase for better statistics

builder = build_scenario_from_payload(preset)
handler = Dnd5e::Simulation::JSONCombatResultHandler.new
runner = Dnd5e::Simulation::Runner.new(scenario: builder.build, result_handler: handler, logger: Logger.new(nil))
runner.run

results = JSON.parse(handler.to_json)
wins = results.group_by { |c| c['winner'] }.transform_values(&:length)

puts "Results for #{preset['name']}:"
wins.each do |team, count|
  puts "  #{team}: #{count} wins (#{(count.to_f / results.length * 100).round(1)}%)"
end
