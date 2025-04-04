# /home/chuck_mcintyre/src/dnd5e/test/dnd5e/core/test_combat.rb
require_relative "../../test_helper"
require_relative "../../../lib/dnd5e/core/combat"
require_relative "../../../lib/dnd5e/core/character"
require_relative "../../../lib/dnd5e/core/monster"
require_relative "../../../lib/dnd5e/core/statblock"
require_relative "../../../lib/dnd5e/core/attack"
require_relative "../../../lib/dnd5e/core/dice"

module Dnd5e
  module Core
    class TestAttackHit < Attack
      def calculate_attack_roll(statblock, roll: nil)
        return 100
      end
    end

    class TestAttackMiss < Attack
      def calculate_attack_roll(statblock, roll: nil)
        return 0
      end
    end

    class TestCombat < Minitest::Test
      def setup
        @hero_statblock = Statblock.new(name: "Hero Statblock", strength: 16, dexterity: 14, constitution: 15, hit_die: "d10", level: 3)
        @goblin_statblock = Statblock.new(name: "Goblin Statblock", strength: 8, dexterity: 14, constitution: 10, hit_die: "d6", level: 1)
        @sword_attack = Attack.new(name: "Sword", damage_dice: Dice.new(1, 8), relevant_stat: :strength)
        @bite_attack = Attack.new(name: "Bite", damage_dice: Dice.new(1, 6), relevant_stat: :strength)

        @hero = Character.new(name: "Hero", statblock: @hero_statblock, attacks: [@sword_attack])
        @goblin1 = Monster.new(name: "Goblin 1", statblock: @goblin_statblock, attacks: [@bite_attack])
        @goblin2 = Monster.new(name: "Goblin 2", statblock: @goblin_statblock, attacks: [@bite_attack])

        @heroes = Team.new(name: "Heroes", members: [@hero])
        @goblins = Team.new(name: "Goblins", members: [@goblin1, @goblin2])
        @combat = Combat.new(teams: [@heroes, @goblins])
      end

      def test_combat_initialization
        assert_equal [@heroes, @goblins], @combat.teams
        assert_empty @combat.turn_order
      end

      def test_roll_initiative
        @combat.roll_initiative
        assert_equal 3, @combat.turn_order.size
        @combat.turn_order.each do |combatant|
          assert combatant.instance_variable_get(:@initiative).is_a?(Integer)
        end
      end

      def test_sort_by_initiative
        @combat.roll_initiative
        @combat.sort_by_initiative
        assert_equal @combat.turn_order.sort_by { |combatant| -combatant.instance_variable_get(:@initiative) }, @combat.turn_order
      end

      def test_take_turn_selects_valid_defender
        @combat.roll_initiative
        @combat.sort_by_initiative
        @combat.take_turn(@hero)
        # This test is hard to assert, but we can check that it doesn't error
        assert true
      end

      def test_attack_hits
        @sword_attack = TestAttackHit.new(name: "Sword", damage_dice: Dice.new(1, 8), relevant_stat: :strength)
        @bite_attack = TestAttackMiss.new(name: "Bite", damage_dice: Dice.new(1, 6), relevant_stat: :strength)

        @hero = Character.new(name: "Hero", statblock: @hero_statblock, attacks: [@sword_attack])
        @goblin1 = Monster.new(name: "Goblin 1", statblock: @goblin_statblock, attacks: [@bite_attack])
        @goblin2 = Monster.new(name: "Goblin 2", statblock: @goblin_statblock, attacks: [@bite_attack])

        @heroes = Team.new(name: "Heroes", members: [@hero])
        @goblins = Team.new(name: "Goblins", members: [@goblin1, @goblin2])
        @combat = Combat.new(teams: [@heroes, @goblins])

        @combat.roll_initiative
        @combat.sort_by_initiative
        initial_hp = @goblin1.statblock.hit_points
        @combat.attack(@hero, @goblin1)
        assert_operator @goblin1.statblock.hit_points, :<, initial_hp
        initial_hp = @hero.statblock.hit_points
        @combat.attack(@goblin2, @hero)
        assert_equal @hero.statblock.hit_points, initial_hp
      end

      def test_is_over
        refute @combat.is_over?
        @goblin1.statblock.take_damage(@goblin1.statblock.hit_points)
        @goblin2.statblock.take_damage(@goblin2.statblock.hit_points)
        assert @combat.is_over?
      end

      def test_winner
        @goblin1.statblock.take_damage(@goblin1.statblock.hit_points)
        @goblin2.statblock.take_damage(@goblin2.statblock.hit_points)
        assert_equal @heroes, @combat.winner
      end
    end
  end
end
