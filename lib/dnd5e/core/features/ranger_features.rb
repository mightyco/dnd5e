# frozen_string_literal: true

require_relative '../feature'

module Dnd5e
  module Core
    module Features
      # Implementation of the Ranger's Hunter's Mark feature (2024).
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
          return if already_active?(attacker) || !can_mark?(attacker)

          consume_resource(attacker)
          attacker.add_condition(:hunters_mark_active)
          combat.notify_observers(:resource_used, { combatant: attacker, resource: :hunters_mark })
          attacker.turn_context.use_bonus_action
        end

        private

        def already_active?(attacker)
          attacker.condition?(:hunters_mark_active)
        end

        def can_mark?(attacker)
          return false unless attacker.turn_context.bonus_action_available?

          attacker.statblock.resources.available?(:hunters_mark) ||
            attacker.statblock.resources.available?(:lvl1_slots)
        end

        def consume_resource(attacker)
          if attacker.statblock.resources.available?(:hunters_mark)
            attacker.statblock.resources.consume(:hunters_mark)
          else
            attacker.statblock.resources.consume(:lvl1_slots)
          end
        end
      end
    end
  end
end
