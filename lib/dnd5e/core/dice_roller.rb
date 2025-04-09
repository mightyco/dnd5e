require_relative "dice"

module Dnd5e
  module Core
    class InvalidDiceNotationError < StandardError; end

    class DiceRoller
      """Rolls dice and returns a sum."""

      def roll(dice_notation)
        # roll("1d20")
        num_dice, sides, modifier = parse_dice_notation(dice_notation)
        @dice = Dice.new(num_dice, sides, modifier: modifier)
        do_roll
      end

      def roll_with_dice(dice)
        @dice = dice
        do_roll
      end

      def roll_with_sides(num_dice, sides, modifier: 0)
        @dice = Dice.new(num_dice, sides, modifier: modifier)
        do_roll
      end

      def roll_with_advantage(sides, modifier: 0)
        @dice = Dice.new(2, sides, modifier: modifier)
        @dice.roll
        @dice.rolls.max + @dice.modifier
      end

      def roll_with_disadvantage(sides, modifier: 0)
        @dice = Dice.new(2, sides, modifier: modifier)
        @dice.roll
        @dice.rolls.min + @dice.modifier
      end

      private

      def do_roll
        @dice.roll
        return @dice.total
      end

      def parse_dice_notation(dice_notation)
        match_data = dice_notation.match(/^(\d*)d(\d+)([+-]\d+)?$/i)
        raise InvalidDiceNotationError, "Invalid dice notation: #{dice_notation}" unless match_data

        num_dice = match_data[1].empty? ? 1 : match_data[1].to_i
        sides = match_data[2].to_i
        modifier = match_data[3].nil? ? 0 : match_data[3].to_i

        raise InvalidDiceNotationError, "Number of dice must be greater than 0" unless num_dice > 0
        raise InvalidDiceNotationError, "Number of sides must be greater than 0" unless sides > 0

        [num_dice, sides, modifier]
      end
    end

    class MockDiceRoller < DiceRoller
      def initialize(rolls)
        @rolls = rolls
        @index = 0
      end

      def roll(*args)
        result = @rolls[@index]
        @index += 1
        result.nil? ? 0 : result
      end

      alias roll_with_sides roll
      alias roll_with_dice roll
      alias roll_with_advantage roll
      alias roll_with_disadvantage roll
    end
  end
end
