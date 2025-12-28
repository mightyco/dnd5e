# frozen_string_literal: true

require_relative 'statblock'
require_relative 'attack'
require_relative 'turn_context'

module Dnd5e
  module Core
    # Represents a character in the D&D 5e system.
    # A character has a name, a statblock, and a list of attacks.
    class Character
      attr_reader :name, :statblock, :turn_context
      attr_accessor :team, :attacks, :spells

      # Initializes a new Character.
      #
      # @param name [String] The name of the character.
      # @param statblock [Statblock] The character's statblock.
      # @param attacks [Array<Attack>] The character's attacks.
      # @param spells [Array<Spell>] The character's known/prepared spells.
      # @param team [Object, nil] The team the character belongs to.
      def initialize(name:, statblock:, attacks: [], spells: [], team: nil)
        @name = name
        @statblock = statblock
        @attacks = attacks
        @spells = spells
        @team = team
        @turn_context = TurnContext.new
      end

      # Prepares the character for the start of their turn.
      def start_turn
        @turn_context.reset!
      end
    end
  end
end
