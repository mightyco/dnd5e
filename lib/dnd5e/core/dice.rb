module Dnd5e
  module Core
    class Dice
      attr_reader :count, :sides

      def initialize(count, sides)
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
