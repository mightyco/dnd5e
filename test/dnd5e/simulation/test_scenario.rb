require_relative "../../test_helper"
require_relative "../../../lib/dnd5e/simulation/scenario"
require_relative "../../../lib/dnd5e/simulation/scenario_builder"
require_relative "../../../lib/dnd5e/core/team"
require_relative "../core/factories"

module Dnd5e
  module Simulation
    class TestScenario < Minitest::Test
      include Core::Factories

      def setup
        @hero1 = CharacterFactory.create_hero
        @hero2 = CharacterFactory.create_hero
        @goblin1 = MonsterFactory.create_goblin
        @goblin2 = MonsterFactory.create_goblin

        @heroes = Core::Team.new(name: "Heroes", members: [@hero1, @hero2])
        @goblins = Core::Team.new(name: "Goblins", members: [@goblin1, @goblin2])
      end

      def test_scenario_initialization
        scenario = Scenario.new(teams: [@heroes, @goblins], num_simulations: 1000)
        assert_equal [@heroes, @goblins], scenario.teams
        assert_equal 1000, scenario.num_simulations
      end

      def test_scenario_builder
        scenario = ScenarioBuilder.new(num_simulations: 500).with_team(@heroes).with_team(@goblins).build
        assert_equal [@heroes, @goblins], scenario.teams
        assert_equal 500, scenario.num_simulations
      end

      def test_scenario_requires_at_least_two_teams
        assert_raises(ArgumentError) { Scenario.new(teams: [@heroes], num_simulations: 1000) }
      end

      def test_scenario_teams_must_be_teams
        assert_raises(ArgumentError) { Scenario.new(teams: [@heroes, "not a team"], num_simulations: 1000) }
      end
    end
  end
end
