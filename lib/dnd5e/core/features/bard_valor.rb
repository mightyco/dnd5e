# frozen_string_literal: true

require_relative '../feature'

module Dnd5e
  module Core
    module Features
      # Implementation of the Bard's College of Valor subclass features.
      class CombatInspiration < Feature
        def initialize
          super(name: 'Combat Inspiration')
        end

        def on_attack_roll(context)
          attacker = context[:attacker]
          return 0 unless eligible_for_inspiration?(attacker, context[:raw_roll])

          apply_inspiration_bonus(attacker)
        end

        private

        def eligible_for_inspiration?(attacker, raw_roll)
          attacker.team &&
            attacker.statblock.resources.available?(:bardic_inspiration) &&
            (8..14).include?(raw_roll)
        end

        def apply_inspiration_bonus(attacker)
          die_size = bardic_inspiration_die(attacker.statblock.level)
          bonus = DiceRoller.new.roll("1d#{die_size}")

          attacker.statblock.resources.consume(:bardic_inspiration)
          attacker.instance_variable_get(:@combat_context)&.notify_observers(
            :resource_used, { combatant: attacker, resource: :bardic_inspiration }
          )
          bonus
        end

        def bardic_inspiration_die(level)
          case level
          when 1..4 then 6
          when 5..9 then 8
          when 10..14 then 10
          else 12
          end
        end
      end
    end
  end
end
