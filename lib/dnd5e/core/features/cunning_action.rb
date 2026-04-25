# frozen_string_literal: true

require_relative '../feature'

module Dnd5e
  module Core
    # Methods for Cunning Action shared between feature and strategy.
    module CunningAction
      def try_cunning_action_hide?(combatant, _combat)
        return false unless combatant.turn_context.bonus_action_available?
        return false if combatant.condition?(:hidden)

        # In a real sim, we'd roll Stealth vs Perception.
        # For simplicity, we'll assume success if they have the feature.
        combatant.add_condition(:hidden)
        combatant.turn_context.use_bonus_action
        true
      end
    end

    module Features
      # Implementation of the Cunning Action class feature.
      class CunningAction < Feature
        include Dnd5e::Core::CunningAction

        def initialize
          super(name: 'Cunning Action')
        end
      end
    end
  end
end
