# frozen_string_literal: true

module Dnd5e
  module Core
    # Formatting logic for the CombatLogger.
    module CombatLogFormatter
      def format_roll_info(result)
        prof = result.proficiency_bonus
        mod = result.modifier - prof
        base_str = "#{'+' if mod.positive?}#{mod} Mod +#{prof} Prof"

        if result.advantage || result.disadvantage
          format_adv_dis_roll(result, base_str)
        else
          "(#{result.raw_roll} #{base_str})"
        end
      end

      private

      def format_adv_dis_roll(result, base_str)
        type = result.advantage ? 'Adv' : 'Dis'
        picked = result.raw_roll
        others = result.rolls.reject.with_index { |_, i| i == result.rolls.index(picked) }
        "(#{type}: [#{picked}, #{others.join(', ')}] -> #{picked} #{base_str})"
      end

      def format_damage_info(result)
        rolls_str = result.damage_rolls.join(' + ')
        "(#{rolls_str} + #{result.damage_modifier})"
      end
    end
  end
end
