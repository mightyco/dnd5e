require_relative "../../test_helper"
require_relative "../../../lib/dnd5e/core/dice_roller"
require_relative "../../../lib/dnd5e/core/dice"

module Dnd5e
  module Core
    class TestDiceRoller < Minitest::Test
      # Looping for Randomness
      def test_roll_with_dice_multiple_times
        100.times do # Run the test 100 times
          dice_roller = DiceRoller.new
          dice = Dice.new(2, 6)
          result = dice_roller.roll_with_dice(dice)
          assert_operator result, :>=, 2
          assert_operator result, :<=, 12
        end
      end

      # Looping for Randomness
      def test_roll_with_sides_multiple_times
        100.times do # Run the test 100 times
          dice_roller = DiceRoller.new
          result = dice_roller.roll_with_sides(3, 4)
          assert_operator result, :>=, 3
          assert_operator result, :<=, 12
        end
      end

      # Parameterization and Edge Cases
      def test_roll_valid_notation_parameterized
        test_cases = [
          { notation: "d20", min: 1, max: 20 },
          { notation: "2d6", min: 2, max: 12 },
          { notation: "1d4", min: 1, max: 4 },
          { notation: "4d10", min: 4, max: 40 },
          { notation: "1d1", min: 1, max: 1 }, # Edge case: minimum sides
          { notation: "100d100", min: 100, max: 10000 }, # Edge case: large numbers
        ]

        test_cases.each do |test_case|
          dice_roller = DiceRoller.new
          result = dice_roller.roll(test_case[:notation])
          assert_operator result, :>=, test_case[:min]
          assert_operator result, :<=, test_case[:max]
        end
      end

      # Parameterization and Edge Cases
      def test_roll_invalid_notation_parameterized
        test_cases = [
          "invalid",
          "d",
          "d0",
          "0d20",
          "2d",
          "d-1", # Edge case: negative sides
          "-1d20", # Edge case: negative dice
        ]

        test_cases.each do |test_case|
          dice_roller = DiceRoller.new
          assert_raises(InvalidDiceNotationError) { dice_roller.roll(test_case) }
        end
      end
    end

    class TestMockDiceRoller < Minitest::Test
      def test_roll_mocked
        mock_dice_roller = MockDiceRoller.new([5, 10, 15])
        assert_equal 5, mock_dice_roller.roll
        assert_equal 10, mock_dice_roller.roll
        assert_equal 15, mock_dice_roller.roll
      end

      def test_roll_mocked_runs_out_of_rolls
        mock_dice_roller = MockDiceRoller.new([5, 10])
        assert_equal 5, mock_dice_roller.roll
        assert_equal 10, mock_dice_roller.roll
        assert_equal 0, mock_dice_roller.roll
        assert_equal 0, mock_dice_roller.roll
      end
    end
  end
end
