# frozen_string_literal: true

require_relative 'base_strategy'
require_relative 'simple_strategy_logic'

module Dnd5e
  module Core
    module Strategies
      # A simple strategy that attacks the first available target.
      class SimpleStrategy < BaseStrategy
        include SimpleStrategyLogic

        def initialize
          super
          @name = 'Simple'
        end

        def execute_turn(combatant, combat)
          try_second_wind(combatant, combat)

          target, attack = prepare_turn_data(combatant, combat)
          move_towards_target(combatant, target, attack, combat) if target && attack

          execute_action(combatant, combat)

          target, attack = prepare_turn_data(combatant, combat)
          move_towards_target(combatant, target, attack, combat) if target && attack

          try_action_surge(combatant, combat)
        end

        private

        def prepare_turn_data(combatant, combat)
          target = find_target(combatant, combat)
          [target, select_attack(combatant, target, combat)]
        end

        def execute_action(combatant, combat)
          return unless combatant.turn_context.action_available?

          target, attack = prepare_turn_data(combatant, combat)
          perform_action_cycle(combatant, target, attack, combat) if target && attack

          combatant.turn_context.use_action
        end

        def perform_action_cycle(combatant, target, attack, combat)
          if in_range?(combatant, target, attack, combat)
            execute_attacks(combatant, target, attack, combat)
          else
            combatant.turn_context.instance_variable_set(:@movement_used, 0)
            move_towards_target(combatant, target, attack, combat)
          end
        end
      end
    end
  end
end
