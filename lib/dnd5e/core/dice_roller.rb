# frozen_string_literal: true

require_relative 'dice'

module Dnd5e
  module Core
    class InvalidDiceNotationError < StandardError; end

    # Handles parsing and rolling of dice notation (e.g., "1d20+5").
    class DiceRoller
      attr_reader :dice

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
        @dice.total
      end

      def parse_dice_notation(dice_notation)
        match_data = dice_notation.match(/^(\d*)d(\d+)([+-]\d+)?$/i)
        raise InvalidDiceNotationError, "Invalid dice notation: #{dice_notation}" unless match_data

        num_dice = match_data[1].empty? ? 1 : match_data[1].to_i
        sides = match_data[2].to_i
        modifier = match_data[3].nil? ? 0 : match_data[3].to_i

        validate_dice_params(num_dice, sides)

        [num_dice, sides, modifier]
      end

      def validate_dice_params(num_dice, sides)
        raise InvalidDiceNotationError, 'Number of dice must be greater than 0' unless num_dice.positive?
        raise InvalidDiceNotationError, 'Number of sides must be greater than 0' unless sides.positive?
      end
    end

    # A dice roller that returns predetermined values for testing.
    class MockDiceRoller < DiceRoller
      attr_accessor :rolls, :calls, :last_dice_params
      attr_writer :index

      def initialize(rolls)
        super()
        @rolls = rolls
        @index = 0
        @calls = []
        @last_dice_params = []
      end

      def roll(*_args)
        @calls << :roll
        next_result
      end

      def roll_with_sides(*_args)
        @calls << :roll_with_sides
        next_result
      end

      def roll_with_dice(dice)
        @dice = dice
        @calls << :roll_with_dice
        @last_dice_params << dice
        next_result
      end

      def roll_with_advantage(sides, modifier: 0)
        # Simulate creating dice to track it
        @dice = Dice.new(2, sides, modifier: modifier)
        @calls << :roll_with_advantage
        next_result
      end

      def roll_with_disadvantage(sides, modifier: 0)
        # Simulate creating dice to track it
        @dice = Dice.new(2, sides, modifier: modifier)
        @calls << :roll_with_disadvantage
        next_result
      end

      private

      def next_result
        result = @rolls[@index]
        @index += 1
        val = result.nil? ? 0 : result

        # Ensure the dice object knows about this roll
        # This is critical for checks like `dice.rolls.include?(20)`
        if @dice
          # We need to hack the dice object to think it rolled this value
          # Dice#roll usually clears and sets @rolls.
          # Here we just append if we are mocking a sequence?
          # Or replace? Dice stores history of one roll action.
          @dice.instance_variable_set(:@rolls, [val])
          @dice.instance_variable_set(:@total, val + @dice.modifier)
        end

        val
      end
    end
  end
end
