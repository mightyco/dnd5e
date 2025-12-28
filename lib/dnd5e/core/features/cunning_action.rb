# frozen_string_literal: true

# require_relative 'strategies/base_strategy' # Circular/incorrect path

module Dnd5e
  module Core
    # A module to be included in Strategies that can use Cunning Action.
    module CunningAction
      # Attempts to use Cunning Action to Hide if eligible.
      #
      # @param combatant [Character] The character attempting to hide.
      # @param combat [Combat] The combat instance.
      # @return [Boolean] true if hidden, false otherwise.
      def try_cunning_action_hide?(combatant, _combat)
        return false unless combatant.turn_context.bonus_action_available?

        # Logic for hiding:
        # 1. Check if obscured (simplified: always yes for now or needs Cover system)
        # 2. Roll Stealth vs Passive Perception (simplified: auto-succeed for now or needs check)

        # For this iteration, we just mark the action used and set a flag.
        combatant.turn_context.use_bonus_action
        combatant.statblock.conditions << :hidden
        true
      end
    end
  end
end
