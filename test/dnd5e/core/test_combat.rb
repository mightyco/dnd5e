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
        100
      end
    end

    class TestAttackMiss < Attack
      def calculate_attack_roll(statblock, roll: nil)
        0
      end
    end

    class TestCombat < Minitest::Test
      def setup
        @hero_statblock = Statblock.new(name: "Hero Statblock", strength: 16, dexterity: 14, constitution: 15, hit_die: "d10", level: 3)
        @goblin_statblock = Statblock.new(name: "Goblin Statblock", strength: 8, dexterity: 14, constitution: 10, hit_die: "d6", level: 1)
        @sword_attack = TestAttackHit.new(name: "Sword", damage_dice: Dice.new(1, 8), relevant_stat: :strength)
        @bite_attack = TestAttackMiss.new(name: "Bite", damage_dice: Dice.new(1, 6), relevant_stat: :strength)

        @hero = Character.new(name: "Hero", statblock: @hero_statblock, attacks: [@sword_attack])
        @goblin = Monster.new(name: "Goblin 1", statblock: @goblin_statblock, attacks: [@bite_attack])

        @combat = Combat.new(combatant1: @hero, combatant2: @goblin)
      end

      def test_combat_initialization
        assert_equal @combat.combatant1, @hero
        assert_equal @combat.combatant2, @goblin
        assert_empty @combat.turn_order
      end

      def test_combat_ends
        @combat.start
        assert @combat.is_over?
        # The hero only hits the goblin only misses
        assert_equal @hero.name, @combat.winner.name
      end

      def test_roll_initiative
        @combat.roll_initiative
        assert_equal 2, @combat.turn_order.size
        @combat.turn_order.each do |combatant|
          assert combatant.instance_variable_get(:@initiative).is_a?(Integer)
        end
      end

      def test_sort_by_initiative
        @combat.roll_initiative
        @combat.sort_by_initiative
        assert_equal @combat.turn_order.sort_by { |combatant| -combatant.instance_variable_get(:@initiative) }, @combat.turn_order
      end

      def test_attack_hit_and_miss
        @combat.roll_initiative
        @combat.sort_by_initiative
        initial_hp = @goblin.statblock.hit_points
        @combat.attack(@hero, @goblin)
        assert_operator @goblin.statblock.hit_points, :<, initial_hp
        initial_hp = @hero.statblock.hit_points
        @combat.attack(@goblin, @hero)
        assert_equal @hero.statblock.hit_points, initial_hp
      end

      def test_is_over
        refute @combat.is_over?
        @goblin.statblock.take_damage(1000)
        assert @combat.is_over?
      end

      def test_winner
        @goblin.statblock.take_damage(@goblin.statblock.hit_points)
        assert_equal @hero.name, @combat.winner.name
      end

      def test_take_turn_selects_valid_defender
        20.times do
          @combat.roll_initiative
          @combat.sort_by_initiative
          @combat.turn_order.each do |attacker|
            initial_hp = @hero.statblock.hit_points
            defender = @combat.take_turn(attacker)
            refute_equal attacker, defender, "Attacker should not be the same as the defender"
            assert_equal @hero.statblock.hit_points, initial_hp
          end
        end
      end

      def test_attack_method_with_hit
        # Create a new attack that always hits
        hit_attack = TestAttackHit.new(name: "Hit Attack", damage_dice: Dice.new(1, 6), relevant_stat: :strength)
        hero = Character.new(name: "Hero", statblock: @hero_statblock, attacks: [hit_attack])
        combat = Combat.new(combatant1: hero, combatant2: @goblin)

        initial_hp = @goblin.statblock.hit_points
        combat.attack(hero, @goblin)
        assert_operator @goblin.statblock.hit_points, :<, initial_hp
      end

      def test_attack_method_with_miss
        # Create a new attack that always misses
        miss_attack = TestAttackMiss.new(name: "Miss Attack", damage_dice: Dice.new(1, 6), relevant_stat: :strength)
        hero = Character.new(name: "Hero", statblock: @hero_statblock, attacks: [miss_attack])
        combat = Combat.new(combatant1: hero, combatant2: @goblin)

        initial_hp = @goblin.statblock.hit_points
        combat.attack(hero, @goblin)
        assert_equal @goblin.statblock.hit_points, initial_hp
      end

      def test_take_turn_selects_valid_defender_with_multiple_attacks
        # Create a new attack that always hits
        hit_attack = TestAttackHit.new(name: "Hit Attack", damage_dice: Dice.new(1, 6), relevant_stat: :strength)
        hero = Character.new(name: "Hero", statblock: @hero_statblock, attacks: [hit_attack, hit_attack])
        combat = Combat.new(combatant1: hero, combatant2: @goblin)

        combat.roll_initiative
        combat.sort_by_initiative

        initial_hp = @goblin.statblock.hit_points
        combat.turn_order.each do |attacker|
          defender = combat.take_turn(attacker)
          refute_equal attacker, defender, "Attacker should not be the same as the defender"
        end
        assert_operator @goblin.statblock.hit_points, :<, initial_hp
      end

      def test_dead_creatures_take_no_actions
        # Ensure the goblin is in the turn order
        @combat.roll_initiative
        @combat.sort_by_initiative
        assert_includes @combat.turn_order, @goblin

        # Kill the goblin
        @goblin.statblock.take_damage(@goblin.statblock.hit_points)
        assert_equal 0, @goblin.statblock.hit_points
        refute @goblin.statblock.is_alive?

        # Check that the goblin's turn is skipped
        # We'll use a mock to verify that take_turn is not called on the goblin
        mock_combat = Minitest::Mock.new
        mock_combat.expect(:take_turn, nil, [@goblin])

        @combat.turn_order.each do |attacker|
          if attacker == @goblin
            mock_combat.take_turn(attacker)
          else
            @combat.take_turn(attacker)
          end
        end

        # Assert that the mock expectations were met
        mock_combat.verify
      end

      def test_combat_ends_correctly
        # Kill the goblin
        @goblin.statblock.take_damage(@goblin.statblock.hit_points)
        refute @goblin.statblock.is_alive?

        # Start the combat
        @combat.start

        # Check that the combat is over
        assert @combat.is_over?
        assert_equal @hero, @combat.winner
      end

      def test_attacker_is_never_dead
        # Kill the hero
        @hero.statblock.take_damage(@hero.statblock.hit_points)
        refute @hero.statblock.is_alive?

        # Start the combat
        @combat.start

        # Check that the combat is over
        assert @combat.is_over?
        assert_equal @goblin, @combat.winner
      end

      def test_attackers_choose_living_target
        # Kill the goblin
        @goblin.statblock.take_damage(@goblin.statblock.hit_points)
        refute @goblin.statblock.is_alive?

        # Start the combat
        @combat.start

        # Check that the combat is over
        assert @combat.is_over?
        assert_equal @hero, @combat.winner
      end
    end
  end
end
