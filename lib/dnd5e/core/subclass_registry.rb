# frozen_string_literal: true

require_relative 'features/battle_master'
require_relative 'features/improved_critical'
require_relative 'strategies/battle_master_strategy'
require_relative 'strategies/simple_strategy'

module Dnd5e
  module Core
    # Maps fighter (and future class) subclasses to their canonical features and strategy.
    # This is the single source of truth for "what does a battlemaster get?".
    class SubclassRegistry
      SUBCLASSES = {
        battlemaster: {
          features: ->(level) { [Features::BattleMaster.new(level: level)] },
          strategy: ->(_level) { Strategies::BattleMasterStrategy.new }
        },
        champion: {
          features: ->(_level) { [Features::ImprovedCritical.new] },
          strategy: ->(_level) { Strategies::SimpleStrategy.new }
        }
      }.freeze

      def self.features_for(subclass, level)
        entry = fetch(subclass)
        entry[:features].call(level)
      end

      def self.strategy_for(subclass, level)
        entry = fetch(subclass)
        entry[:strategy].call(level)
      end

      def self.known?(subclass)
        SUBCLASSES.key?(subclass.to_sym)
      end

      def self.fetch(subclass)
        SUBCLASSES.fetch(subclass.to_sym) do
          raise ArgumentError, "Unknown subclass: #{subclass}. Known: #{SUBCLASSES.keys.join(', ')}"
        end
      end
      private_class_method :fetch
    end
  end
end
