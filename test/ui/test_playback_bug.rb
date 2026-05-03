# frozen_string_literal: true

require_relative '../test_helper'
require_relative '../../lib/dnd5e/simulation/json_combat_result_handler'
require_relative '../../lib/dnd5e/simulation/runner'
require_relative '../../lib/dnd5e/simulation/scenario_builder'
require_relative '../../lib/dnd5e/builders/character_builder'

class TestPlaybackBug < Minitest::Test
  def test_snapshots_contain_all_combatants
    scenario = build_test_scenario
    handler = Dnd5e::Simulation::JSONCombatResultHandler.new(capture_snapshots: true)
    Dnd5e::Simulation::Runner.new(scenario: scenario, result_handler: handler, logger: Logger.new(nil)).run

    first_combat = JSON.parse(handler.to_json).first
    verify_initial_positions(first_combat)
    verify_event_snapshots(first_combat)
  end

  private

  def build_test_scenario
    hero = Dnd5e::Builders::CharacterBuilder.new(name: 'Hero').as_fighter.build
    monster = Dnd5e::Builders::MonsterBuilder.new(name: 'Bugbear').as_bugbear.build

    team_h = Dnd5e::Core::Team.new(name: 'Heroes', members: [hero])
    team_m = Dnd5e::Core::Team.new(name: 'Monsters', members: [monster])

    Dnd5e::Simulation::ScenarioBuilder.new(num_simulations: 1)
                                      .with_team(team_h)
                                      .with_team(team_m)
                                      .build
  end

  def verify_initial_positions(combat)
    assert_equal 2, combat['initial_positions'].keys.length
    assert_includes combat['initial_positions'], 'Hero'
    assert_includes combat['initial_positions'], 'Bugbear'
  end

  def verify_event_snapshots(combat)
    combat['rounds'].each do |round|
      round['events'].each do |event|
        next unless event['snapshot']

        assert_equal 2, event['snapshot'].keys.length, "Snapshot missing combatants in round #{round['number']}"
        assert_includes event['snapshot'], 'Hero'
        assert_includes event['snapshot'], 'Bugbear'
      end
    end
  end
end
