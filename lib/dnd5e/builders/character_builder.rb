module Dnd5e
  module Builders
    # Builds a Character object with a fluent interface.
    class CharacterBuilder
      # Error raised when an invalid character is built.
      class InvalidCharacterError < StandardError; end

      # Initializes a new CharacterBuilder.
      #
      # @param name [String] The name of the character.
      def initialize(name:)
        @name = name
        @statblock = nil
        @attacks = []
      end

      # Sets the statblock for the character.
      #
      # @param statblock [Statblock] The statblock for the character.
      # @return [CharacterBuilder] The CharacterBuilder instance.
      def with_statblock(statblock)
        @statblock = statblock
        self
      end

      # Adds an attack to the character.
      #
      # @param attack [Attack] The attack to add.
      # @return [CharacterBuilder] The CharacterBuilder instance.
      def with_attack(attack)
        @attacks << attack
        self
      end

      # Builds the character.
      #
      # @return [Character] The built character.
      # @raise [InvalidCharacterError] if the character is invalid.
      def build
        raise InvalidCharacterError, "Character must have a name" if @name.nil? || @name.empty?
        raise InvalidCharacterError, "Character must have a statblock" if @statblock.nil?

        Core::Character.new(name: @name, statblock: @statblock, attacks: @attacks)
      end
    end
  end
end
