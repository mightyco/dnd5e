# frozen_string_literal: true

require_relative 'base_strategy'

module Dnd5e
  module Core
    module Strategies
      # A simple strategy that attacks the first available target.
      class SimpleStrategy < BaseStrategy
        def execute_turn(combatant, combat)
          # Currently only supports one Action per turn
          return unless combatant.turn_context.action_available?

          target = find_target(combatant, combat)
          return unless target

          # Execute the attack via the combat engine
          combat.attack(combatant, target)

          # Mark action as used
          combatant.turn_context.use_action
        end

        private

        def find_target(combatant, combat)
          # This relies on Combat exposing a way to find targets.
          # Previously Combat#find_valid_defender was private.
          # We might need to make it public or expose combatants.

          # Assuming we can access combatants
          (combat.combatants - [combatant]).find { |c| c.statblock.alive? }
        end
      end
    end
  end
end
