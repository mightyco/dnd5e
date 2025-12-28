# frozen_string_literal: true

require_relative '../dice'

module Dnd5e
  module Core
    module Helpers
      # Helper for calculating and rolling damage.
      class DamageRollHelper
        def self.calculate_dice(attacker, attack, is_crit, options)
          base_dice = attack.damage_dice_for(attacker.statblock.level)
          context = { attacker: attacker, attack: attack, dice: base_dice, options: options, is_crit: is_crit }
          base_dice = attacker.feature_manager.apply_hook(:on_damage_calculation, context, base_dice)

          count = is_crit ? base_dice.count * 2 : base_dice.count
          Dice.new(count, base_dice.sides, modifier: base_dice.modifier)
        end

        def self.roll_extra(attacker, defender, attack, options)
          context = { attacker: attacker, defender: defender, attack: attack, options: options }
          extra_dice_list = attacker.feature_manager.apply_list_hook(:extra_damage_dice, context)

          total = 0
          all_rolls = []
          extra_dice_list.each do |dice|
            total += attack.dice_roller.roll_with_dice(dice)
            all_rolls.concat(attack.dice_roller.dice.rolls)
          end
          [total, all_rolls]
        end
      end
    end
  end
end
