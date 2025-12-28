# frozen_string_literal: true

require_relative 'statblock'
require_relative 'attack'
require_relative 'turn_context'
require_relative 'feature_manager'
require_relative 'strategies/simple_strategy'

module Dnd5e
  module Core
    # Represents a character in the D&D 5e system.
    # A character has a name, a statblock, and a list of attacks.
    class Character
      attr_reader :name, :statblock, :turn_context, :feature_manager
      attr_accessor :team, :attacks, :spells, :strategy

      # Initializes a new Character.
      #
      # @param name [String] The name of the character.
      # @param statblock [Statblock] The character's statblock.
      # @param attacks [Array<Attack>] The character's attacks.
      # @param spells [Array<Spell>] The character's known/prepared spells.
      # @param team [Object, nil] The team the character belongs to.
      # @param strategy [Strategy] The strategy to use for combat (default: SimpleStrategy).
      # @param options [Hash] Additional options (attacks, spells, team, features).
      def initialize(name:, statblock:, strategy: Strategies::SimpleStrategy.new, **options)
        @name = name
        @statblock = statblock
        @attacks = options[:attacks] || []
        @spells = options[:spells] || []
        @team = options[:team]
        @turn_context = TurnContext.new
        @strategy = strategy
        @feature_manager = FeatureManager.new(options[:features] || [])
      end

      # Prepares the character for the start of their turn.
      def start_turn
        @turn_context.reset!
      end
    end
  end
end
