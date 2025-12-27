# frozen_string_literal: true

require_relative '../../test_helper'
require_relative '../../../lib/dnd5e/simulation/scenario'
require_relative '../../../lib/dnd5e/simulation/scenario_builder'
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
        hero_statblock = Core::Statblock.new(name: 'Hero Statblock', strength: 16, dexterity: 10, constitution: 15,
                                             hit_die: 'd10', level: 3)
        goblin_statblock = Core::Statblock.new(name: 'Goblin Statblock', strength: 8, dexterity: 14, constitution: 10,
                                               hit_die: 'd6', level: 1)
        sword_attack = Core::Attack.new(name: 'Sword', damage_dice: Core::Dice.new(1, 8), relevant_stat: :strength)
        bite_attack = Core::Attack.new(name: 'Bite', damage_dice: Core::Dice.new(1, 6), relevant_stat: :dexterity)

        @hero1 = Builders::CharacterBuilder.new(name: 'Hero1')
                                           .with_statblock(hero_statblock.deep_copy)
                                           .with_attack(sword_attack)
                                           .build
        @hero2 = Builders::CharacterBuilder.new(name: 'Hero2')
                                           .with_statblock(hero_statblock.deep_copy)
                                           .with_attack(sword_attack)
                                           .build
        @goblin1 = Builders::MonsterBuilder.new(name: 'Goblin1')
                                           .with_statblock(goblin_statblock.deep_copy)
                                           .with_attack(bite_attack)
                                           .build
        @goblin2 = Builders::MonsterBuilder.new(name: 'Goblin2')
                                           .with_statblock(goblin_statblock.deep_copy)
                                           .with_attack(bite_attack)
                                           .build

        @heroes = Core::Team.new(name: 'Heroes', members: [@hero1, @hero2])
        @goblins = Core::Team.new(name: 'Goblins', members: [@goblin1, @goblin2])
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
        assert_raises(ArgumentError) { Scenario.new(teams: [@heroes, 'not a team'], num_simulations: 1000) }
      end
    end
  end
end
