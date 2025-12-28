# frozen_string_literal: true

module Dnd5e
  module Core
    # Formatting logic for the CombatLogger.
    module CombatLogFormatter
      def format_roll_info(result)
        if result.advantage || result.disadvantage
          type = result.advantage ? 'Adv' : 'Dis'
          picked = result.raw_roll
          others = result.rolls.reject.with_index { |_, i| i == result.rolls.index(picked) }
          "(#{type}: [#{picked}, #{others.join(', ')}] -> #{picked} + #{result.modifier})"
        else
          "(#{result.raw_roll} + #{result.modifier})"
        end
      end

      def format_damage_info(result)
        rolls_str = result.damage_rolls.join(' + ')
        "(#{rolls_str} + #{result.damage_modifier})"
      end
    end
  end
end
