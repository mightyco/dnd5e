require_relative "../../test_helper"
require_relative "../../../lib/dnd5e/core/dice_roller"
require_relative "../../../lib/dnd5e/core/dice"

module Dnd5e
  module Core
    class TestDiceRoller < Minitest::Test
      def test_roll_with_dice
        dice_roller = DiceRoller.new
        dice = Dice.new(2, 6)
        result = dice_roller.roll_with_dice(dice)
        assert_operator result, :>=, 2
        assert_operator result, :<=, 12
      end

      def test_roll_with_sides
        dice_roller = DiceRoller.new
        result = dice_roller.roll_with_sides(3, 4)
        assert_operator result, :>=, 3
        assert_operator result, :<=, 12
      end

      def test_roll_valid_notation
        dice_roller = DiceRoller.new
        result = dice_roller.roll("d20")
        assert_operator result, :>=, 1
        assert_operator result, :<=, 20

        result = dice_roller.roll("2d6")
        assert_operator result, :>=, 2
        assert_operator result, :<=, 12

        result = dice_roller.roll("1d4")
        assert_operator result, :>=, 1
        assert_operator result, :<=, 4

        result = dice_roller.roll("4d10")
        assert_operator result, :>=, 4
        assert_operator result, :<=, 40
      end

      def test_roll_invalid_notation
        dice_roller = DiceRoller.new
        assert_raises(InvalidDiceNotationError) { dice_roller.roll("invalid") }
        assert_raises(InvalidDiceNotationError) { dice_roller.roll("d") }
        assert_raises(InvalidDiceNotationError) { dice_roller.roll("d0") }
        assert_raises(InvalidDiceNotationError) { dice_roller.roll("0d20") }
        assert_raises(InvalidDiceNotationError) { dice_roller.roll("2d") }
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
