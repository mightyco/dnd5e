# frozen_string_literal: true

require_relative 'simple_strategy'

module Dnd5e
  module Core
    module Strategies
      # Strategy for Monks.
      class MonkStrategy < SimpleStrategy
        def initialize
          super
          @name = 'Monk'
        end

        def execute_turn(combatant, combat)
          target, attack = prepare_turn_data(combatant, combat)
          move_towards_target(combatant, target, attack, combat) if target && attack

          execute_action(combatant, combat)
          try_monk_bonus_action(combatant, combat)
        end

        private

        def try_monk_bonus_action(combatant, combat)
          return unless combatant.turn_context.bonus_action_available?

          target = find_monk_bonus_target(combatant, combat)
          return unless target

          attack = combatant.attacks.find { |a| a.name == 'Unarmed Strike' }
          return unless attack

          execute_bonus_logic(combatant, target, attack, combat)
        end

        def find_monk_bonus_target(combatant, combat)
          target, _atk = prepare_turn_data(combatant, combat)
          return target if target && in_range?(combatant, target, nil, combat)

          nil
        end

        def execute_bonus_logic(combatant, target, attack, combat)
          flurry_feat = combatant.feature_manager.features.find { |f| f.name == 'Flurry of Blows' }
          if flurry_feat&.try_activate(combatant, combat)
            execute_flurry(combatant, target, attack, combat)
          else
            execute_martial_arts(combatant, target, attack)
          end
        end

        def execute_flurry(combatant, target, attack, combat)
          # Clone the attack to rename it for trigger matching
          flurry_attack = attack.dup
          flurry_attack.instance_variable_set(:@name, 'Flurry of Blows')

          combat.attack(combatant, target, attack: flurry_attack)
          target = ensure_alive_target(combatant, target, combat)
          combat.attack(combatant, target, attack: flurry_attack) if target
        end

        def execute_martial_arts(combatant, target, attack)
          combatant.instance_variable_get(:@combat_context)&.attack(combatant, target, attack: attack)
          combatant.turn_context.use_bonus_action
        end
      end
    end
  end
end
