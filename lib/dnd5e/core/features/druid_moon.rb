# frozen_string_literal: true

require_relative '../feature'

module Dnd5e
  module Core
    module Features
      # Implementation of the Druid's Circle of the Moon subclass features.
      class CombatWildShape < Feature
        def initialize(level:)
          super(name: 'Combat Wild Shape')
          @level = level
        end

        # 2024 Rules: Bonus Action to Wild Shape.
        # Temporary HP = 3x Druid Level.
        # AC = 13 + Wisdom Modifier (if higher than current).
        def try_activate(attacker, combat)
          return unless can_wild_shape?(attacker)

          apply_wild_shape(attacker)
          apply_temp_hp(attacker)

          combat.notify_observers(:resource_used, { combatant: attacker, resource: :wild_shape })
          attacker.turn_context.use_bonus_action
        end

        private

        def can_wild_shape?(attacker)
          !attacker.condition?(:wild_shaped) &&
            attacker.statblock.resources.available?(:wild_shape) &&
            attacker.turn_context.bonus_action_available?
        end

        def apply_wild_shape(attacker)
          attacker.statblock.resources.consume(:wild_shape)
          attacker.add_condition(:wild_shaped)
        end

        def apply_temp_hp(attacker)
          temp_hp = @level * 3
          current_temp = attacker.statblock.instance_variable_get(:@temp_hp) || 0
          attacker.statblock.instance_variable_set(:@temp_hp, [current_temp, temp_hp].max)
        end

        # AC modification logic would need to be in Statblock or a hook.
        # For now, we'll assume the strategy handles the "Form" attacks.
      end

      # Implementation of the Druid's Primal Strike feature.
      class PrimalStrike < Feature
        def initialize
          super(name: 'Primal Strike')
        end

        def on_damage_calculation(context)
          # 2024: You can deal Force damage instead of the normal damage type.
          # In this simulation, we'll just tag it or keep it as is,
          # as damage types aren't fully resisted yet.
        end
      end
    end
  end
end
