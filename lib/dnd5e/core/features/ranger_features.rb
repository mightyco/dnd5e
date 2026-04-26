# frozen_string_literal: true

require_relative '../feature'

module Dnd5e
  module Core
    module Features
      # rubocop:disable Naming/VariableNumber
      # Implementation of the Ranger's Hunter's Mark feature.
      class HuntersMark < Feature
        def initialize
          super(name: "Hunter's Mark")
        end

        def on_attack_hit(context)
          attacker = context[:attacker]
          return unless attacker.condition?(:hunters_mark_active)

          extra_damage = DiceRoller.new.roll('1d6')
          context[:result][:damage] += extra_damage
        end

        def try_activate(attacker, combat)
          return if attacker.condition?(:hunters_mark_active)
          return unless attacker.statblock.resources.available?(:spell_slot_1)
          return unless attacker.turn_context.bonus_action_available?

          attacker.statblock.resources.consume(:spell_slot_1)
          attacker.add_condition(:hunters_mark_active)
          combat.notify_observers(:resource_used, { combatant: attacker, resource: :spell_slot_1 })
          attacker.turn_context.use_bonus_action
        end
      end
      # rubocop:enable Naming/VariableNumber

      # Implementation of the Ranger's Hunter subclass: Colossus Slayer.
      class ColossusSlayer < Feature
        def initialize
          super(name: 'Colossus Slayer')
        end

        def on_attack_hit(context)
          attacker = context[:attacker]
          defender = context[:defender]

          return if defender.statblock.hit_points >= defender.statblock.calculate_hit_points
          return if attacker.turn_context.instance_variable_get(:@colossus_slayer_used)

          extra_damage = DiceRoller.new.roll('1d8')
          context[:result][:damage] += extra_damage
          attacker.turn_context.instance_variable_set(:@colossus_slayer_used, true)
        end
      end
    end
  end
end
