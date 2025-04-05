require_relative "../../test_helper"
require_relative "../../../lib/dnd5e/core/attack"
require_relative "../../../lib/dnd5e/core/statblock"
require_relative "../../../lib/dnd5e/core/dice"
require 'minitest/mock'

module Dnd5e
  module Core
    class TestAttackRoll < Minitest::Test
      def setup
        @statblock = Statblock.new(name: "TestStatblock", strength: 14, dexterity: 12, constitution: 10, intelligence: 8, wisdom: 16, charisma: 18, hit_die: "d8", level: 1)
        @attack = Attack.new(name: "Sword", damage_dice: Dice.new(1, 8), extra_attack_bonus: 2, extra_damage_bonus: 1, relevant_stat: :strength)
      end

      def test_initialize
        assert_equal "Sword", @attack.name
        assert_equal 1, @attack.damage_dice.count
        assert_equal 8, @attack.damage_dice.sides
        assert_equal 2, @attack.attack_bonus
        assert_equal 1, @attack.damage_bonus
        assert_equal :melee, @attack.range
        assert_equal 1, @attack.count
        assert_equal :strength, @attack.relevant_stat
      end

      def test_calculate_attack_roll
        # Pass in a fixed roll value for testing
        assert_equal 16, @attack.calculate_attack_roll(@statblock, roll: 10) # 10 (roll) + 2 (extra_attack_bonus) + 2 (strength modifier) + 2 (proficiency bonus)
      end

      def test_calculate_damage
        # Mock the damage_dice.roll.sum to return a fixed value for testing
        @attack.damage_dice.stub(:roll, [5]) do
          damage = @attack.calculate_damage(@statblock)
          assert_equal 8, damage # 5 (roll) + 1 (extra_damage_bonus) + 2 (strength modifier)
        end
      end

      def test_calculate_attack_bonus
        attack_bonus = @attack.calculate_attack_bonus(@statblock)
        assert_equal 6, attack_bonus # 2 (extra_attack_bonus) + 2 (strength modifier) + 2 (proficiency bonus)
      end

      def test_calculate_damage_bonus
        damage_bonus = @attack.calculate_damage_bonus(@statblock)
        assert_equal 3, damage_bonus # 1 (extra_damage_bonus) + 2 (strength modifier)
      end

      def test_initialize_with_range
        attack = Attack.new(name: "Bow", damage_dice: Dice.new(1, 6), range: :ranged)
        assert_equal :ranged, attack.range
      end

      def test_initialize_with_count
        attack = Attack.new(name: "Multiattack", damage_dice: Dice.new(1, 4), count: 2)
        assert_equal 2, attack.count
      end

      def test_initialize_with_relevant_stat
        attack = Attack.new(name: "Dagger", damage_dice: Dice.new(1, 4), relevant_stat: :dexterity)
        assert_equal :dexterity, attack.relevant_stat
      end
    end
  end
end
