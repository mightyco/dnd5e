require_relative "../../test_helper"
require_relative "../../../lib/dnd5e/simulation/runner"
require_relative "../../../lib/dnd5e/core/team_combat"
require_relative "../../../lib/dnd5e/core/team"
require_relative "../../../lib/dnd5e/core/simulation_combat_result_handler"
require_relative "../core/factories"

module Dnd5e
  module Simulation
    # Move MockBattleScenario outside of TestRunner
    class MockBattleScenario
      include Core::Factories # Include the module here

      def initialize
        @hero1 = CharacterFactory.create_hero
        @hero2 = CharacterFactory.create_hero
        @goblin1 = MonsterFactory.create_goblin
        @goblin2 = MonsterFactory.create_goblin

        @heroes = Core::Team.new(name: "Heroes", members: [@hero1, @hero2])
        @goblins = Core::Team.new(name: "Goblins", members: [@goblin1, @goblin2])
        @combat = Core::TeamCombat.new(teams: [@heroes, @goblins], result_handler: Core::SimulationCombatResultHandler.new)
      end

      def start
        # Return a Result object
        @combat.start
      end
    end

    class TestRunner < Minitest::Test
      include Core::Factories

      def setup
        @hero1 = CharacterFactory.create_hero
        @hero2 = CharacterFactory.create_hero
        @goblin1 = MonsterFactory.create_goblin
        @goblin2 = MonsterFactory.create_goblin

        @heroes = Core::Team.new(name: "Heroes", members: [@hero1, @hero2])
        @goblins = Core::Team.new(name: "Goblins", members: [@goblin1, @goblin2])
      end

      def test_runner_initialization
        runner = Runner.new(MockBattleScenario, num_simulations: 50)
        assert_equal MockBattleScenario, runner.battle_scenario
        assert_equal 50, runner.num_simulations
        assert_empty runner.results
      end

      def test_run_battle
        runner = Runner.new(MockBattleScenario, num_simulations: 1)
        result = runner.run_battle
        assert_instance_of Result, result
      end

      def test_run
        runner = Runner.new(MockBattleScenario, num_simulations: 5)
        runner.run
        assert_equal 5, runner.results.size
        runner.results.each do |result|
          assert_instance_of Result, result
        end
      end

      def test_generate_report
        runner = Runner.new(MockBattleScenario, num_simulations: 5)
        runner.run
        assert_output(/Simulation Report/) { runner.generate_report }
      end
    end
  end
end
