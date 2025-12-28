# frozen_string_literal: true

require_relative '../../test_helper'
require_relative '../../../lib/dnd5e/simulation/scenario'
require_relative '../../../lib/dnd5e/core/team'
require_relative '../../../lib/dnd5e/builders/character_builder'
require_relative '../../../lib/dnd5e/builders/monster_builder'
require_relative '../../../lib/dnd5e/core/statblock'
require_relative '../../../lib/dnd5e/core/attack'
require_relative '../../../lib/dnd5e/core/dice'

module Dnd5e
  module Simulation
    class TestScenario < Minitest::Test
      def setup
        @hero_team = create_team('Heroes', ['Hero 1', 'Hero 2'], Builders::CharacterBuilder)
        @goblin_team = create_team('Goblins', ['Goblin 1', 'Goblin 2'], Builders::MonsterBuilder)
        @teams = [@hero_team, @goblin_team]
      end

      def create_team(team_name, member_names, builder_class)
        members = member_names.map do |name|
          builder_class.new(name: name)
                       .with_statblock(Core::Statblock.new(name: 'Base'))
                       .with_attack(Core::Attack.new(name: 'Base Attack', damage_dice: Core::Dice.new(1, 6)))
                       .build
        end
        Core::Team.new(name: team_name, members: members)
      end

      def test_scenario_initialization
        scenario = Scenario.new(teams: @teams, num_simulations: 100)

        assert_equal @teams, scenario.teams
        assert_equal 100, scenario.num_simulations
      end

      def test_scenario_requires_at_least_two_teams
        assert_raises(ArgumentError) do
          Scenario.new(teams: [@hero_team], num_simulations: 100)
        end
      end

      def test_scenario_requires_valid_teams
        assert_raises(ArgumentError) do
          Scenario.new(teams: [@hero_team, 'not a team'], num_simulations: 100)
        end
      end
    end
  end
end
