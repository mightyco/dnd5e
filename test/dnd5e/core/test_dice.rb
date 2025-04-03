require_relative "../../test_helper"

module Dnd5e
  module Core
    class TestDice < Minitest::Test
      def test_initialize
        dice = Dice.new(2, 6)
        assert_equal 2, dice.count
        assert_equal 6, dice.sides
      end

      def test_roll
        dice = Dice.new(3, 4)
        rolls = dice.roll
        assert_equal 3, rolls.length
        rolls.each do |roll|
          assert roll >= 1
          assert roll <= 4
        end
      end

      def test_total
        dice = Dice.new(2, 6)
        rolls = dice.roll
        expected_total = rolls.sum
        assert_equal expected_total, dice.total
      end

      def test_to_s
        dice = Dice.new(1, 20)
        assert_equal "1d20", dice.to_s
      end
    end
  end
end
