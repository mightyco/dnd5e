# frozen_string_literal: true

require_relative '../../test_helper'
require_relative '../../../lib/dnd5e/simulation/runner'
require_relative '../../../lib/dnd5e/simulation/simulation_combat_result_handler'
require_relative '../../../lib/dnd5e/simulation/scenario_builder'
require_relative '../../../lib/dnd5e/builders/character_builder'
require_relative '../../../lib/dnd5e/builders/monster_builder'
require_relative '../../../lib/dnd5e/core/statblock'
require_relative '../../../lib/dnd5e/core/attack'
require_relative '../../../lib/dnd5e/core/dice'

module Dnd5e
  module Integration
    class TestSimulationBalance < Minitest::Test
      def setup
        @attempts = 500 # Reduced from 1000 for speed in tests, usually balance tests need more though.
        # But this is just checking the simulation runs and produces vaguely expected results.
      end

      def test_balanced_combat_win_rates
        # Identical fighters should have ~50% win rate
        scenario = create_balanced_scenario
        handler = Simulation::SimulationCombatResultHandler.new
        runner = Simulation::Runner.new(scenario: scenario, result_handler: handler, logger: Logger.new(nil))

        runner.run

        report = handler.report(@attempts)
        check_balance(report, 'Fighter 1')
        check_balance(report, 'Fighter 2')
      end

      private

      def create_balanced_scenario
        fighter_block = Core::Statblock.new(name: 'Fighter', strength: 16, dexterity: 14, constitution: 14,
                                            hit_die: 'd10', level: 1)
        sword = Core::Attack.new(name: 'Sword', damage_dice: Core::Dice.new(1, 8), relevant_stat: :strength)

        t1 = create_team('Fighter 1', fighter_block, sword)
        t2 = create_team('Fighter 2', fighter_block, sword)

        Simulation::ScenarioBuilder.new(num_simulations: @attempts).with_team(t1).with_team(t2).build
      end

      def create_team(name, statblock, attack)
        char = Builders::CharacterBuilder.new(name: name)
                                         .with_statblock(statblock.deep_copy)
                                         .with_attack(attack)
                                         .build
        Core::Team.new(name: name, members: [char])
      end

      def check_balance(report, team_name)
        match = report.match(/#{team_name} won (\d+\.\d+)%/)
        win_rate = match[1].to_f
        # Allow wide margin for randomness in small sample size test
        assert_operator win_rate, :>=, 40.0
        assert_operator win_rate, :<=, 60.0
      end
    end
  end
end
