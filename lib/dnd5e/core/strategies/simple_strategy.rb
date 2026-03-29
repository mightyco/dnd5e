# frozen_string_literal: true

require_relative 'base_strategy'
require_relative 'simple_strategy_logic'

module Dnd5e
  module Core
    module Strategies
      # A simple strategy that attacks the first available target.
      class SimpleStrategy < BaseStrategy
        include SimpleStrategyLogic

        def execute_turn(combatant, combat)
          try_second_wind(combatant, combat)
          execute_action(combatant, combat)
          try_action_surge(combatant, combat)
        end

        private

        def execute_action(combatant, combat)
          return unless combatant.turn_context.action_available?

          target = find_target(combatant, combat)
          attack = select_attack(combatant, combat)
          return unless target && attack

          move_towards_target(combatant, target, attack, combat)
          return unless in_range?(attack, combat)

          execute_attacks(combatant, target, attack, combat)
          combatant.turn_context.use_action
        end
      end
    end
  end
end
