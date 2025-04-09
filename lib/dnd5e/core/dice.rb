# lib/dnd5e/core/dice.rb
module Dnd5e
  module Core
    # Error raised when an invalid dice count is provided.
    class InvalidDiceCountError < StandardError; end
    # Error raised when an invalid number of dice sides is provided.
    class InvalidDiceSidesError < StandardError; end
    # Error raised when invalid rolls are provided.
    class InvalidRollsError < StandardError; end

    # Represents a set of dice with a specific number of sides and a modifier.
    class Dice
      # @return [Integer] The number of dice.
      attr_reader :count
      # @return [Integer] The number of sides on each die.
      attr_reader :sides
      # @return [Integer] The modifier to be added to the total roll.
      attr_reader :modifier
      # @return [Array<Integer>] The individual rolls of the dice.
      attr_reader :rolls

      # Initializes a new Dice object.
      #
      # @param count [Integer] The number of dice to roll. Must be greater than 0.
      # @param sides [Integer] The number of sides on each die. Must be greater than 0.
      # @param rolls [Array<Integer>, nil] An optional array of pre-determined rolls.
      # @param modifier [Integer] A modifier to be added to the total roll. Defaults to 0.
      # @raise [InvalidDiceCountError] if count is not greater than 0.
      # @raise [InvalidDiceSidesError] if sides is not greater than 0.
      # @raise [InvalidRollsError] if rolls is not an array or contains invalid values.
      def initialize(count, sides, rolls: nil, modifier: 0)
        raise InvalidDiceCountError, "Dice count must be greater than 0" unless count > 0
        raise InvalidDiceSidesError, "Dice sides must be greater than 0" unless sides > 0
        validate_rolls(rolls, sides) if rolls

        @count = count
        @sides = sides
        @rolls = rolls || []
        @modifier = modifier
      end

      # Rolls the dice and stores the results.
      #
      # @return [Array<Integer>] The individual rolls of the dice.
      def roll
        @rolls = [] # Clear previous rolls
        @count.times do
          @rolls << rand(1..@sides)
        end
        @rolls
      end

      # Calculates the total of the dice rolls plus the modifier.
      #
      # @return [Integer] The total of the dice rolls plus the modifier.
      def total
        @rolls.sum + @modifier
      end

      # Returns a string representation of the dice.
      #
      # @return [String] A string in the format "NdS+M" (e.g., "2d6+3").
      def to_s
        modifier_str = @modifier.positive? ? "+#{@modifier}" : @modifier.to_s
        modifier_str = "" if @modifier == 0
        "#{@count}d#{@sides}#{modifier_str}"
      end

      private

      # Validates the rolls array.
      #
      # @param rolls [Array<Integer>] The rolls to validate.
      # @param sides [Integer] The number of sides on each die.
      # @raise [InvalidRollsError] if rolls is not an array or contains invalid values.
      def validate_rolls(rolls, sides)
        unless rolls.is_a?(Array)
          raise InvalidRollsError, "Rolls must be an array"
        end
        if rolls.any? { |roll| roll < 1 || roll > sides }
          raise InvalidRollsError, "Rolls must be between 1 and #{sides}"
        end
      end
    end
  end
end
