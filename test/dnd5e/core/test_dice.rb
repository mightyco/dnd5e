require_relative "../../test_helper"
require 'minitest/mock'

module Dnd5e
  module Core
    class TestDice < Minitest::Test
      def test_initialize_with_valid_arguments
        dice = Dice.new(2, 6)
        assert_equal 2, dice.count
        assert_equal 6, dice.sides
      end

      def test_initialize_with_invalid_count
        assert_raises(Dnd5e::Core::InvalidDiceCountError) { Dice.new(0, 6) }
        assert_raises(Dnd5e::Core::InvalidDiceCountError) { Dice.new(-1, 6) }
      end

      def test_initialize_with_invalid_sides
        assert_raises(Dnd5e::Core::InvalidDiceSidesError) { Dice.new(2, 0) }
        assert_raises(Dnd5e::Core::InvalidDiceSidesError) { Dice.new(2, -1) }
      end

      def test_roll_returns_array
        dice = Dice.new(3, 4)
        rolls = dice.roll
        assert_instance_of Array, rolls
      end

      def test_roll_returns_correct_number_of_rolls
        dice = Dice.new(3, 4)
        rolls = dice.roll
        assert_equal 3, rolls.length
      end

      def test_roll_returns_rolls_within_correct_range
        dice = Dice.new(100, 4)
        rolls = dice.roll
        rolls.each do |roll|
          assert roll >= 1
          assert roll <= 4
        end
      end

      def test_total_returns_correct_sum
        dice = Dice.new(2, 6, rolls: [1, 2])
        assert_equal 3, dice.total

        dice = Dice.new(3, 4, rolls: [1, 2, 3])
        assert_equal 6, dice.total
      end

      def test_to_s_returns_correct_string_representation
        dice = Dice.new(1, 20)
        assert_equal "1d20", dice.to_s
        dice = Dice.new(3, 6)
        assert_equal "3d6", dice.to_s
      end

      def test_initialize_with_invalid_rolls
        assert_raises(Dnd5e::Core::InvalidRollsError) { Dice.new(2, 6, rolls: "not an array") }
        assert_raises(Dnd5e::Core::InvalidRollsError) { Dice.new(2, 6, rolls: [0, 1]) }
        assert_raises(Dnd5e::Core::InvalidRollsError) { Dice.new(2, 6, rolls: [7, 1]) }
      end

      def test_total_with_modifier
        dice = Dice.new(2, 6, rolls: [1, 2], modifier: 3)
        assert_equal 6, dice.total

        dice = Dice.new(3, 4, rolls: [1, 2, 3], modifier: -2)
        assert_equal 4, dice.total
      end

      def test_to_s_with_modifier
        dice = Dice.new(2, 6, modifier: 3)
        assert_equal "2d6+3", dice.to_s

        dice = Dice.new(3, 4, modifier: -2)
        assert_equal "3d4-2", dice.to_s

        dice = Dice.new(1, 20, modifier: 0)
        assert_equal "1d20", dice.to_s
      end
    end
  end
end
