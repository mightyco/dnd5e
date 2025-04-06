module Dnd5e
  module Core
    class DiceRoller
      def roll(dice)
        dice.roll.sum
      end
    end

    class MockDiceRoller < DiceRoller
      def initialize(rolls)
        @rolls = rolls
        @index = 0
      end
    
      def roll(dice)
        result = @rolls[@index]
        @index += 1
        # Return a default value if we run out of rolls
        result.nil? ? 0 : result
      end
    end
  end
end
