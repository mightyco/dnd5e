# frozen_string_literal: true

require_relative '../feature'

module Dnd5e
  module Core
    module Features
      # Implementation of the Paladin's Divine Smite feature.
      class DivineSmite < Feature
        def initialize
          super(name: 'Divine Smite')
        end

        def on_attack_hit(context)
          attacker = context[:attacker]
          return unless can_smite?(attacker)

          slot = find_highest_slot(attacker)
          return unless slot

          execute_smite(attacker, slot, context[:result])
        end

        private

        def can_smite?(attacker)
          attacker.turn_context.bonus_action_available? &&
            !attacker.turn_context.instance_variable_get(:@smite_used)
        end

        def find_highest_slot(attacker)
          attacker.statblock.resources.resources.keys
                  .select { |k| k.to_s.match?(/lvl\d_slots/) }
                  .select { |k| attacker.statblock.resources.available?(k) }
                  .sort.reverse.first
        end

        def execute_smite(attacker, slot, result)
          slot_level = slot.to_s.match(/lvl(\d)_slots/)[1].to_i
          attacker.statblock.resources.consume(slot)
          attacker.turn_context.use_bonus_action
          attacker.turn_context.instance_variable_set(:@smite_used, true)

          damage = DiceRoller.new.roll("#{1 + slot_level}d8")
          apply_smite_damage(attacker, slot, result, damage)
        end

        def apply_smite_damage(attacker, slot, result, damage)
          result[:damage] += damage
          attacker.instance_variable_get(:@combat_context)&.notify_observers(
            :resource_used, { combatant: attacker, resource: slot }
          )
        end
      end

      # Implementation of the Oath of Devotion's Sacred Weapon.
      class SacredWeapon < Feature
        def initialize
          super(name: 'Sacred Weapon')
        end

        def on_attack_roll(context)
          attacker = context[:attacker]
          return 0 unless attacker.condition?(:sacred_weapon)

          attacker.statblock.ability_modifier(:charisma)
        end

        def try_activate(attacker, combat)
          return if attacker.condition?(:sacred_weapon)
          return unless attacker.statblock.resources.available?(:channel_divinity)
          return unless attacker.turn_context.bonus_action_available?

          attacker.statblock.resources.consume(:channel_divinity)
          attacker.add_condition(:sacred_weapon, { expiry: :turn_end, duration: 10 })
          combat.notify_observers(:resource_used, { combatant: attacker, resource: :channel_divinity })
          attacker.turn_context.use_bonus_action
        end
      end
    end
  end
end
