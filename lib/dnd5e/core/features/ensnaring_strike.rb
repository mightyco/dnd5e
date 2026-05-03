# frozen_string_literal: true

require_relative '../feature'

module Dnd5e
  module Core
    module Features
      # Implementation of the Ensnaring Strike spell (2024).
      # As a Bonus Action, next time you hit, target is Restrained on fail STR save.
      class EnsnaringStrike < Feature
        def initialize
          super(name: 'Ensnaring Strike')
        end

        # rubocop:disable Naming/PredicateMethod
        def activate(attacker, combat)
          return false if active?(attacker) || !can_cast?(attacker)

          attacker.statblock.resources.consume(:lvl1_slots)
          attacker.turn_context.flags[:ensnaring_strike_active] = true
          combat.notify_observers(:resource_used, { combatant: attacker, resource: :lvl1_slots })
          attacker.turn_context.use_bonus_action
          true
        end
        # rubocop:enable Naming/PredicateMethod

        def on_attack_hit(context)
          attacker = context[:attacker]
          return unless attacker.turn_context.flags[:ensnaring_strike_active]

          # Consume the active spell on hit
          attacker.turn_context.flags[:ensnaring_strike_active] = false
          resolve_save(context[:defender], attacker, context[:combat])
        end

        private

        def active?(attacker)
          attacker.turn_context.flags[:ensnaring_strike_active]
        end

        def can_cast?(attacker)
          attacker.statblock.resources.available?(:lvl1_slots) &&
            attacker.turn_context.bonus_action_available?
        end

        def resolve_save(defender, attacker, combat)
          dc = 8 + attacker.statblock.ability_modifier(:wisdom) + attacker.statblock.proficiency_bonus
          save_roll = defender.statblock.save_modifier(:strength) + DiceRoller.new.roll('1d20')

          return unless save_roll < dc

          defender.add_condition(:restrained, { duration: 10, expiry: :turn_start })
          combat&.notify_observers(:condition_applied, { target: defender, condition: :restrained })
        end
      end
    end
  end
end
