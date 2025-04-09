require_relative "statblock"
require_relative "attack"

module Dnd5e
  module Core
    # Represents a character in the D&D 5e system.
    # A character has a name, a statblock, and a list of attacks.
    class Character
      attr_reader :name, :statblock, :attacks
      attr_accessor :team

      # Initializes a new Character.
      #
      # @param name [String] The name of the character.
      # @param statblock [Statblock] The character's statblock.
      # @param attacks [Array<Attack>] The character's attacks.
      # @param team [Object, nil] The team the character belongs to.
      def initialize(name:, statblock:, attacks: [], team: nil)
        @name = name
        @statblock = statblock
        @attacks = attacks
        @team = team
      end
    end
  end
end
