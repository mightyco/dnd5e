require_relative "../../test_helper"
require_relative "../../../lib/dnd5e/core/dice_roller"
require_relative "../../../lib/dnd5e/core/dice"

module Dnd5e
  module Core
    class TestDiceRoller < Minitest::Test
      def test_roll
        dice_roller = DiceRoller.new
        dice = Dice.new(2, 6)
        result = dice_roller.roll(dice)
        assert_operator result, :>=, 2
        assert_operator result, :<=, 12
      end
    end

    class TestMockDiceRoller < Minitest::Test
      def test_roll
        mock_dice_roller = MockDiceRoller.new([5, 10, 15])
        dice = Dice.new(1, 6)
        assert_equal 5, mock_dice_roller.roll(dice)
        assert_equal 10, mock_dice_roller.roll(dice)
        assert_equal 15, mock_dice_roller.roll(dice)
      end
    end
  end
end
