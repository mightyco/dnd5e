# frozen_string_literal: true

require_relative 'simple_strategy'

module Dnd5e
  module Core
    module Strategies
      # Strategy for Clerics.
      class ClericStrategy < SimpleStrategy
        def initialize
          super
          @name = 'Cleric'
        end

        def execute_turn(combatant, combat)
          target, attack = prepare_turn_data(combatant, combat)
          return unless target

          return if try_divine_spark(combatant, target, combat)

          move_towards_target(combatant, target, attack, combat) if attack
          execute_action(combatant, combat)
        end

        private

        def try_divine_spark(combatant, target, combat)
          spark_feat = combatant.feature_manager.features.find { |f| f.name == 'Divine Spark' }
          spark_feat&.try_activate(combatant, target, combat)
        end
      end
    end
  end
end
