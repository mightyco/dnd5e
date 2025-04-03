module Dnd5e
  module Core
    class InvalidDiceCountError < StandardError; end
    class InvalidDiceSidesError < StandardError; end
    class Dice
      attr_reader :count, :sides

      def initialize(count, sides)
        raise InvalidDiceCountError, "Dice count must be greater than 0" unless count > 0
        raise InvalidDiceSidesError, "Dice sides must be greater than 0" unless sides > 0

        @count = count
        @sides = sides

      end

      def roll
        rolls = []
        @count.times do
          rolls << (1 + rand(@sides))
        end
        rolls
      end

      def total
        roll.sum
      end

      def to_s
        "#{@count}d#{@sides}"
      end
    end
  end
end
