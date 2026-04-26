# frozen_string_literal: true

require_relative 'simple_strategy'

module Dnd5e
  module Core
    module Strategies
      # Strategy for Barbarians.
      class BarbarianStrategy < SimpleStrategy
        def initialize
          super
          @name = 'Barbarian'
        end

        def execute_turn(combatant, combat)
          try_rage(combatant, combat)

          target, attack = prepare_turn_data(combatant, combat)
          move_towards_target(combatant, target, attack, combat) if target && attack

          execute_action(combatant, combat)
        end

        private

        def try_rage(combatant, combat)
          return if combatant.condition?(:raging)
          return unless combatant.statblock.resources.available?(:rage)
          return unless combatant.turn_context.bonus_action_available?

          # Only rage if there's a target within reach or we expect combat
          target = find_target(combatant, combat)
          return unless target

          combatant.statblock.resources.consume(:rage)
          combatant.add_condition(:raging)
          combat.notify_observers(:resource_used, { combatant: combatant, resource: :rage })
          combatant.turn_context.use_bonus_action
        end

        def execute_sequence_attack(combatant, target, attack, combat)
          # Barbarians use Reckless Attack
          options = { attack: attack, combat: combat }
          if attack.relevant_stat == :strength
            options[:advantage] = true
            options[:reckless] = true
            # 2024: Reckless grants advantage against you until start of your next turn
            combatant.add_condition(:reckless_defense, { expiry: :turn_start })
          end

          combat.attack(combatant, target, **options)
          combatant.statblock.resources.consume(attack.resource_cost) if attack.resource_cost
        end
      end
    end
  end
end
