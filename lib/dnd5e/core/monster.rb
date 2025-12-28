# frozen_string_literal: true

require_relative 'statblock'
require_relative 'attack'

require_relative 'feature_manager'
require_relative 'turn_context'

module Dnd5e
  module Core
    # Represents a monster in the D&D 5e system.
    # A monster has a name, a statblock, and a list of attacks.
    class Monster
      attr_reader :name, :statblock, :attacks, :turn_context, :feature_manager
      attr_accessor :team, :strategy

      # Initializes a new Monster.
      #
      # @param name [String] The name of the monster.
      # @param statblock [Statblock] The monster's statblock.
      # @param strategy [Strategy] The strategy to use for combat (default: SimpleStrategy).
      # @param options [Hash] Additional options (attacks, team, features).
      def initialize(name:, statblock:, strategy: Strategies::SimpleStrategy.new, **options)
        @name = name
        @statblock = statblock
        @strategy = strategy
        @attacks = options[:attacks] || []
        @team = options[:team]
        @turn_context = TurnContext.new
        @feature_manager = FeatureManager.new(options[:features] || [])
      end

      # Prepares the monster for the start of their turn.
      def start_turn
        @turn_context.reset!
      end
    end
  end
end
