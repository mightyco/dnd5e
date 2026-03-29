# frozen_string_literal: true

require 'minitest/autorun'
require 'json'
require 'json-schema'
require_relative '../../lib/dnd5e/simulation/runner'
require_relative '../../lib/dnd5e/simulation/scenario_builder'
require_relative '../../lib/dnd5e/simulation/json_combat_result_handler'
require_relative '../../lib/dnd5e/builders/character_builder'
require_relative '../../lib/dnd5e/builders/monster_builder'

# End-to-end flow tests for the Simulation Dashboard pipeline
class E2EFlowTest < Minitest::Test
  SCHEMA_PATH = File.expand_path('schemas/simulation_response.json', __dir__)
  OUTPUT_FILE = 'test_e2e_results.json'

  def test_full_simulation_to_json_flow
    runner = setup_simulation_runner
    runner.run
    runner.export_json(OUTPUT_FILE)

    assert_path_exists OUTPUT_FILE, "Output file #{OUTPUT_FILE} was not created"
    verify_output_file
  ensure
    FileUtils.rm_f(OUTPUT_FILE)
  end

  private

  def verify_output_file
    results = JSON.parse(File.read(OUTPUT_FILE))

    assert_equal 5, results.length
    JSON::Validator.validate!(SCHEMA_PATH, results)
    audit_results(results)
  end

  def setup_simulation_runner
    hero = Dnd5e::Builders::CharacterBuilder.new(name: 'E2E Hero').as_fighter(level: 3).build
    goblin = Dnd5e::Builders::MonsterBuilder.new(name: 'E2E Goblin').as_goblin.build
    scenario = build_scenario([hero], [goblin])
    handler = Dnd5e::Simulation::JSONCombatResultHandler.new
    Dnd5e::Simulation::Runner.new(scenario: scenario, result_handler: handler, logger: Logger.new(nil))
  end

  def build_scenario(heroes, monsters)
    team_h = Dnd5e::Core::Team.new(name: 'Heroes', members: heroes)
    team_m = Dnd5e::Core::Team.new(name: 'Monsters', members: monsters)
    Dnd5e::Simulation::ScenarioBuilder.new(num_simulations: 5).with_team(team_h).with_team(team_m).build
  end

  def audit_results(results)
    results.each do |combat|
      combat['rounds'].each do |round|
        round['events'].each { |event| verify_event_math(event, round['number']) }
      end
    end
  end

  def verify_event_math(event, round_num)
    return unless event['damage'].positive?

    meta = event['metadata']
    actual = event['damage']
    expected = meta['damage_rolls'].sum + meta['damage_modifier']

    assert_equal expected, actual, "Math breakdown failure in round #{round_num}"
  end
end
