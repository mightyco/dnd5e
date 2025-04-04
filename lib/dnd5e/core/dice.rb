# /home/chuck_mcintyre/src/dnd5e/lib/dnd5e/core/dice.rb
module Dnd5e
  module Core
    class InvalidDiceCountError < StandardError; end
    class InvalidDiceSidesError < StandardError; end
    class InvalidRollsError < StandardError; end

    class Dice
      attr_reader :count, :sides

      def initialize(count, sides, rolls: nil)
        raise InvalidDiceCountError, "Dice count must be greater than 0" unless count > 0
        raise InvalidDiceSidesError, "Dice sides must be greater than 0" unless sides > 0
        if rolls && !rolls.is_a?(Array)
          raise InvalidRollsError, "Rolls must be an array"
        end
        if rolls && rolls.any? { |roll| roll < 1 || roll > sides }
          raise InvalidRollsError, "Rolls must be between 1 and #{sides}"
        end

        @count = count
        @sides = sides
        @rolls = rolls || []
      end

      def roll
        @rolls = [] # Clear previous rolls
        @count.times do
          @rolls << rand(1..@sides)
        end
        @rolls
      end

      def total
        @rolls.sum
      end

      def to_s
        "#{@count}d#{@sides}"
      end
    end
  end
end
