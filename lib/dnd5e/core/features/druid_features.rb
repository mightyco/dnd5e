# frozen_string_literal: true

require_relative '../feature'

module Dnd5e
  module Core
    module Features
      # Implementation of the Druid's Wild Shape feature.
      class WildShape < Feature
        def initialize
          super(name: 'Wild Shape')
        end

        def try_activate(attacker, combat)
          return if attacker.condition?(:wild_shaped)
          return unless attacker.statblock.resources.available?(:wild_shape)
          return unless attacker.turn_context.bonus_action_available?

          apply_transformation(attacker, combat)
          true
        end

        def on_damage_calculation(context)
          attacker = context[:attacker]
          return nil unless attacker.condition?(:wild_shaped)

          # While Wild Shaped, use 'Beast Strike' instead of standard weapons
          attacker.statblock.ability_modifier(:wisdom)
          Dice.new(1, 8, modifier: attacker.statblock.ability_modifier(:wisdom))
        end

        private

        def apply_transformation(attacker, combat)
          attacker.statblock.resources.consume(:wild_shape)
          attacker.add_condition(:wild_shaped, { expiry: :turn_end, duration: 100 })

          # For simulation, Wild Shape grants Temp HP equal to 3x Level (simplified)
          attacker.statblock.instance_variable_set(:@temporary_hit_points, attacker.statblock.level * 3)

          combat.notify_observers(:resource_used, { combatant: attacker, resource: :wild_shape })
          attacker.turn_context.use_bonus_action
        end
      end
    end
  end
end
