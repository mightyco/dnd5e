# /home/chuck_mcintyre/src/dnd5e/test/dnd5e/core/test_team.rb
require_relative "../../test_helper"
require_relative "../../../lib/dnd5e/core/team"
require_relative "factories"

module Dnd5e
  module Core
    class TestTeam < Minitest::Test
      include Factories

      def setup
        @hero = CharacterFactory.create_hero
        @hero2 = CharacterFactory.create_hero
        @goblin1 = MonsterFactory.create_goblin
        @goblin2 = MonsterFactory.create_goblin
      end

      def test_team_initialization
        team = Team.new(name: "Heroes", members: [@hero, @hero2])
        assert_equal "Heroes", team.name
        assert_equal [@hero, @hero2], team.members
        assert_equal team, @hero.team
        assert_equal team, @hero2.team
      end

      def test_add_member
        team = Team.new(name: "Heroes", members: [@hero])
        team.add_member(@hero2)
        assert_equal [@hero, @hero2], team.members
        assert_equal team, @hero2.team
      end

      def test_all_members_defeated
        team = Team.new(name: "Goblins", members: [@goblin1, @goblin2])
        refute team.all_members_defeated?
        @goblin1.statblock.take_damage(@goblin1.statblock.hit_points)
        refute team.all_members_defeated?
        @goblin2.statblock.take_damage(@goblin2.statblock.hit_points)
        assert team.all_members_defeated?
      end

      def test_any_members_alive
        team = Team.new(name: "Goblins", members: [@goblin1, @goblin2])
        assert @goblin1.statblock.is_alive?
        assert @goblin2.statblock.is_alive?
        assert team.any_members_alive?
        @goblin1.statblock.take_damage(@goblin1.statblock.hit_points)
        refute @goblin1.statblock.is_alive?, "goblin1 should be dead: #{@goblin1.statblock.hit_points}"
        assert @goblin2.statblock.is_alive?, "goblin2 should be alive: #{@goblin2.statblock.hit_points}"
        assert team.any_members_alive?, "#{@goblin1.statblock} is dead and #{@goblin2.statblock} is alive"
        @goblin2.statblock.take_damage(@goblin2.statblock.hit_points)
        refute @goblin1.statblock.is_alive?
        refute @goblin2.statblock.is_alive?
        refute team.any_members_alive?, "#{@goblin1.statblock} and #{@goblin2.statblock} are dead"
      end

      def test_alive_members
        team = Team.new(name: "Goblins", members: [@goblin1, @goblin2])
        assert_equal [@goblin1, @goblin2], team.alive_members
        @goblin1.statblock.take_damage(@goblin1.statblock.hit_points)
        assert_equal [@goblin2], team.alive_members
        @goblin2.statblock.take_damage(@goblin2.statblock.hit_points)
        assert_equal [], team.alive_members
      end
    end
  end
end
