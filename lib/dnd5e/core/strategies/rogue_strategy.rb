# frozen_string_literal: true

require_relative 'base_strategy'
require_relative '../features/cunning_action'

module Dnd5e
  module Core
    module Strategies
      # A strategy for Rogues that utilizes Cunning Action.
      class RogueStrategy < BaseStrategy
        include Dnd5e::Core::CunningAction

        def execute_turn(combatant, combat)
          # 1. Try to Hide (Bonus Action) to gain Advantage
          try_cunning_action_hide?(combatant, combat)

          # 2. Attack (Action)
          execute_attack(combatant, combat)
        end

        private

        def execute_attack(combatant, combat)
          return unless combatant.turn_context.action_available?

          target = find_target(combatant, combat)
          return unless target

          attack_with_potential_advantage(combatant, combat, target)
          combatant.turn_context.use_action
        end

        def attack_with_potential_advantage(combatant, combat, target)
          # Determine if we have advantage (from being hidden)
          options = {}
          if combatant.statblock.conditions.include?(:hidden)
            options[:advantage] = true
            # Attacking reveals position
            combatant.statblock.conditions.delete(:hidden)
          end

          combat.attack(combatant, target, **options)
        end

        def find_target(combatant, combat)
          (combat.combatants - [combatant]).find { |c| c.statblock.alive? }
        end
      end
    end
  end
end
