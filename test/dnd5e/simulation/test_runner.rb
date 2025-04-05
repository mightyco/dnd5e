require_relative "../../test_helper"
require_relative "../../../lib/dnd5e/simulation/runner"
require_relative "../../../lib/dnd5e/simulation/mock_battle_scenario"
require_relative "../../../lib/dnd5e/simulation/silent_combat_result_handler"
require_relative "../../../lib/dnd5e/simulation/simulation_combat_result_handler"
require_relative "../../../lib/dnd5e/core/team"
require_relative "../core/factories"

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
      end

      def test_runner_initialization
        runner = Runner.new(MockBattleScenario, num_simulations: 50, result_handler: SilentCombatResultHandler.new, teams: @teams)
        assert_equal MockBattleScenario, runner.battle_scenario
        assert_equal 50, runner.num_simulations
        assert_empty runner.results
      end

      def test_run_battle
        result_handler = SilentCombatResultHandler.new
        runner = Runner.new(MockBattleScenario, num_simulations: 1, result_handler: result_handler, teams: @teams)
        runner.run_battle
        assert_equal 1, runner.results.size
        assert_instance_of Result, runner.results.first
      end

      def test_run
        result_handler = SilentCombatResultHandler.new
        runner = Runner.new(MockBattleScenario, num_simulations: 5, result_handler: result_handler, teams: @teams)
        runner.run
        assert_equal 5, runner.results.size
        runner.results.each do |result|
          assert_instance_of Result, result
        end
      end

      def test_generate_report
        result_handler = SimulationCombatResultHandler.new
        runner = Runner.new(MockBattleScenario, num_simulations: 5, result_handler: result_handler, teams: @teams)
        runner.run
        assert_output(/Simulation Report/) { runner.generate_report }
      end
    end
  end
end
