# frozen_string_literal: true

require_relative '../../test_helper'
require_relative '../../../lib/dnd5e/core/team'
require_relative '../../../lib/dnd5e/builders/character_builder'
require_relative '../../../lib/dnd5e/builders/monster_builder'
require_relative '../../../lib/dnd5e/core/statblock'
require_relative '../../../lib/dnd5e/core/attack'
require_relative '../../../lib/dnd5e/core/dice'

module Dnd5e
  module Core
    class TestTeam < Minitest::Test
      def setup
        @goblin_statblock = Statblock.new(name: 'Goblin Statblock', strength: 8, dexterity: 14,
                                          constitution: 10, hit_die: 'd6', level: 1)
        @bite_attack = Attack.new(name: 'Bite', damage_dice: Dice.new(1, 6), relevant_stat: :dexterity)

        @goblin1 = create_goblin('Goblin 1')
        @goblin2 = create_goblin('Goblin 2')

        @team = Team.new(name: 'Goblins', members: [@goblin1, @goblin2])
      end

      def create_goblin(name)
        Builders::MonsterBuilder.new(name: name)
                                .with_statblock(@goblin_statblock.deep_copy)
                                .with_attack(@bite_attack)
                                .build
      end

      def test_initialization
        assert_equal 'Goblins', @team.name
        assert_equal [@goblin1, @goblin2], @team.members
        assert_equal @team, @goblin1.team
        assert_equal @team, @goblin2.team
      end

      def test_add_member
        goblin3 = create_goblin('Goblin 3')
        @team.add_member(goblin3)

        assert_includes @team.members, goblin3
        assert_equal @team, goblin3.team
      end

      def test_all_members_defeated
        refute_predicate @team, :all_members_defeated?

        @goblin1.statblock.take_damage(@goblin1.statblock.hit_points)

        refute_predicate @team, :all_members_defeated?

        @goblin2.statblock.take_damage(@goblin2.statblock.hit_points)

        assert_predicate @team, :all_members_defeated?
      end

      def test_any_members_alive_initially
        assert_predicate @team, :any_members_alive?
      end

      def test_any_members_alive_partial
        @goblin1.statblock.take_damage(@goblin1.statblock.hit_points)

        refute_predicate @goblin1.statblock, :alive?
        assert_predicate @goblin2.statblock, :alive?
        assert_predicate @team, :any_members_alive?
      end

      def test_any_members_alive_none
        kill_member(@goblin1)
        kill_member(@goblin2)

        refute_predicate @team, :any_members_alive?
      end

      def test_alive_members
        assert_equal [@goblin1, @goblin2], @team.alive_members

        kill_member(@goblin1)

        assert_equal [@goblin2], @team.alive_members

        kill_member(@goblin2)

        assert_empty @team.alive_members
      end

      private

      def kill_member(member)
        member.statblock.take_damage(member.statblock.hit_points)
      end
    end
  end
end
