require_relative "../../test_helper"
require_relative "../../../lib/dnd5e/simulation/runner"
require_relative "../../../lib/dnd5e/simulation/mock_battle_scenario"
require_relative "../../../lib/dnd5e/simulation/silent_combat_result_handler"
require_relative "../../../lib/dnd5e/simulation/simulation_combat_result_handler"
require_relative "../../../lib/dnd5e/core/team"
require_relative "../core/factories"

require "logger"

module Dnd5e
  module Simulation
    class TestRunner < Minitest::Test
      include Core::Factories

      def setup
        @hero1 = CharacterFactory.create_hero
        @hero2 = CharacterFactory.create_hero
        @goblin1 = MonsterFactory.create_goblin
        @goblin2 = MonsterFactory.create_goblin

        @heroes = Core::Team.new(name: "Heroes", members: [@hero1, @hero2])
        @goblins = Core::Team.new(name: "Goblins", members: [@goblin1, @goblin2])
        @teams = [@heroes, @goblins]

        @logger = Logger.new(nil)
      end

      def test_runner_initialization
        runner = Runner.new(MockBattleScenario, num_simulations: 50, result_handler: SilentCombatResultHandler.new, teams: @teams, logger: @logger)
        assert_equal MockBattleScenario, runner.battle_scenario
        assert_equal 50, runner.num_simulations
        assert_empty runner.results
      end

      def test_run_battle
        result_handler = SilentCombatResultHandler.new
        runner = Runner.new(MockBattleScenario, num_simulations: 1, result_handler: result_handler, teams: @teams, logger: @logger)
        runner.run_battle
        assert_equal 1, runner.results.size
        assert_instance_of Result, runner.results.first
      end

      def test_run
        result_handler = SilentCombatResultHandler.new
        runner = Runner.new(MockBattleScenario, num_simulations: 5, result_handler: result_handler, teams: @teams, logger: @logger)
        runner.run
        assert_equal 5, runner.results.size
        runner.results.each do |result|
          assert_instance_of Result, result
        end
      end

      def test_generate_report
        result_handler = SimulationCombatResultHandler.new
        runner = Runner.new(MockBattleScenario, num_simulations: 5, result_handler: result_handler, teams: @teams, logger: @logger)
        runner.run
        assert_output(/Simulation Report/) { runner.generate_report }
      end

      def test_simulation_resets_between_runs
        attempts = 100
        # Create a new result handler for this test
        result_handler = SimulationCombatResultHandler.new

        # Create a new runner for this test
        runner = Runner.new(
          MockBattleScenario,
          num_simulations: attempts,
          result_handler: result_handler,
          teams: @teams,
          logger: @logger
        )

        # Run the simulation
        runner.run

        # Check if the results are different
        assert_equal attempts, result_handler.results.size

        # Check if there is a mix of winners
        winners = result_handler.results.map(&:winner).uniq
        assert_operator winners.size, :>=, 2, "Expected at least two different winners in #{attempts} simulations"
      end
    end
  end
end
