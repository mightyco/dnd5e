# frozen_string_literal: true

require_relative '../dice'

module Dnd5e
  module Core
    module Helpers
      # Helper for attack calculations.
      class AttackRollHelper
        def self.roll_attack(attacker, attack, options)
          modifier = attacker.statblock.ability_modifier(attack.relevant_stat)
          modifier -= 5 if options[:great_weapon_master] || options[:sharpshooter]

          if options[:advantage]
            attack.dice_roller.roll_with_advantage(20, modifier: modifier)
          elsif options[:disadvantage]
            attack.dice_roller.roll_with_disadvantage(20, modifier: modifier)
          else
            attack_dice = Dice.new(1, 20, modifier: modifier)
            attack.dice_roller.roll_with_dice(attack_dice)
          end
        end

        def self.critical_hit?(attack, options)
          rolls = attack.dice_roller.dice&.rolls
          return false unless rolls

          natural_roll = select_natural_roll(rolls, options)
          natural_roll == 20
        end

        def self.select_natural_roll(rolls, options)
          if options[:advantage]
            rolls.max
          elsif options[:disadvantage]
            rolls.min
          else
            rolls.first
          end
        end
      end
    end
  end
end
