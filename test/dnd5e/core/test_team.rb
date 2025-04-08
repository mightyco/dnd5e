require_relative "../../test_helper"
require_relative "../../../lib/dnd5e/core/team"
require_relative "../../../lib/dnd5e/core/statblock"
require_relative "../../../lib/dnd5e/builders/character_builder"
require_relative "../../../lib/dnd5e/builders/monster_builder"
require_relative "../../../lib/dnd5e/core/attack"
require_relative "../../../lib/dnd5e/core/dice"

module Dnd5e
  module Core
    class TestTeam < Minitest::Test
      def setup
        hero_statblock = Statblock.new(name: "Hero Statblock", strength: 16, dexterity: 10, constitution: 15, hit_die: "d10", level: 3)
        sword_attack = Attack.new(name: "Sword", damage_dice: Dice.new(1, 8), relevant_stat: :strength)

        @hero = Builders::CharacterBuilder.new(name: "Hero")
                                          .with_statblock(hero_statblock.deep_copy)
                                          .with_attack(sword_attack)
                                          .build
        @hero2 = Builders::CharacterBuilder.new(name: "Hero2")
                                           .with_statblock(hero_statblock.deep_copy)
                                           .with_attack(sword_attack)
                                           .build
        @goblin1 = Builders::MonsterBuilder.new(name: "Goblin1")
                                            .with_statblock(Statblock.new(name: "Goblin Statblock", strength: 8, dexterity: 14, constitution: 10, hit_die: "d6", level: 1))
                                            .with_attack(Attack.new(name: "Bite", damage_dice: Dice.new(1, 6), relevant_stat: :dexterity))
                                            .build
        @goblin2 = Builders::MonsterBuilder.new(name: "Goblin2")
                                            .with_statblock(Statblock.new(name: "Goblin Statblock", strength: 8, dexterity: 14, constitution: 10, hit_die: "d6", level: 1))
                                            .with_attack(Attack.new(name: "Bite", damage_dice: Dice.new(1, 6), relevant_stat: :dexterity))
                                            .build
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
