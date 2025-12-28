# frozen_string_literal: true

require_relative '../../test_helper'
require_relative '../../../lib/dnd5e/core/dice_roller'
require_relative '../../../lib/dnd5e/core/dice'

module Dnd5e
  module Core
    class TestDiceRoller < Minitest::Test
      def test_roll_valid_notation
        roller = DiceRoller.new

        assert_includes 1..20, roller.roll('1d20')
        assert_includes 5..15, roller.roll('2d6+3')
        assert_includes(-1..8, roller.roll('1d10-2'))
      end

      def test_roll_valid_notation_parameterized
        roller = DiceRoller.new

        [
          ['1d4', 1..4], ['1d6', 1..6], ['1d8', 1..8],
          ['1d10', 1..10], ['1d12', 1..12], ['1d20', 1..20]
        ].each do |notation, range|
          assert_includes range, roller.roll(notation)
        end
      end

      def test_roll_invalid_notation
        roller = DiceRoller.new
        assert_raises(InvalidDiceNotationError) { roller.roll('invalid') }
        assert_includes 1..20, roller.roll('d20')
        assert_raises(InvalidDiceNotationError) { roller.roll('1d0') }
      end

      def test_roll_invalid_notation_parameterized
        roller = DiceRoller.new

        ['1d', 'd', '1d-5', '1 d 20'].each do |notation|
          assert_raises(InvalidDiceNotationError) { roller.roll(notation) }
        end
      end

      def test_roll_with_dice
        roller = DiceRoller.new
        dice = Dice.new(2, 6, modifier: 2)

        assert_includes 4..14, roller.roll_with_dice(dice)
      end

      def test_roll_with_sides
        roller = DiceRoller.new

        assert_includes 4..14, roller.roll_with_sides(2, 6, modifier: 2)
      end

      def test_roll_with_advantage
        roller = DiceRoller.new

        assert_includes 1..20, roller.roll_with_advantage(20)
      end

      def test_roll_with_disadvantage
        roller = DiceRoller.new

        assert_includes 1..20, roller.roll_with_disadvantage(20)
      end

      def test_mock_dice_roller
        mock = MockDiceRoller.new([10, 5, 20])

        assert_equal 10, mock.roll('1d20')
        assert_equal 5, mock.roll('1d20')
        assert_equal 20, mock.roll('1d20')
        assert_equal 0, mock.roll('1d20')
      end
    end
  end
end
