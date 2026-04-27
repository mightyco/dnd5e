# frozen_string_literal: true

require_relative '../feature'

module Dnd5e
  module Core
    module Features
      # Implementation of the Bard's Bardic Inspiration feature.
      class BardicInspiration < Feature
        def initialize
          super(name: 'Bardic Inspiration')
        end

        def try_activate(attacker, _target, combat)
          return unless attacker.statblock.resources.available?(:bardic_inspiration)
          return unless attacker.turn_context.bonus_action_available?

          target_ally = find_inspiration_target(attacker, combat)
          apply_inspiration(attacker, target_ally, combat)
          true
        end

        def on_after_attack_roll(context)
          attacker = context[:attacker]
          roll_data = context[:current_value]
          return nil unless attacker.condition?(:inspired)

          ac = context[:defender].statblock.armor_class
          return nil if roll_data[:total] >= ac

          # Use inspiration if it would make a difference
          attacker.remove_condition(:inspired)
          bonus = DiceRoller.new.roll('1d6')
          roll_data[:total] += bonus
          roll_data
        end

        private

        def find_inspiration_target(attacker, combat)
          allies = combat.combatants.select do |c|
            c != attacker && !combat.enemy?(attacker, c) && c.statblock.alive?
          end
          allies.first || attacker
        end

        def apply_inspiration(attacker, target, combat)
          attacker.statblock.resources.consume(:bardic_inspiration)
          target.add_condition(:inspired, { die: 6, expiry: :turn_end, duration: 100 })
          combat.notify_observers(:resource_used, { combatant: attacker, resource: :bardic_inspiration })
          attacker.turn_context.use_bonus_action
        end
      end
    end
  end
end
