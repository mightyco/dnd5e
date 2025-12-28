# frozen_string_literal: true

require_relative '../dice'

module Dnd5e
  module Core
    module Helpers
      # Helper for attack calculations.
      class AttackRollHelper
        def self.roll_attack(attacker, defender, attack, options)
          modifier = calculate_modifier(attacker, attack, options)
          advantage, disadvantage = determine_advantage_disadvantage(attacker, defender, attack, options)

          execute_roll(attack, modifier, advantage, disadvantage)
        end

        def self.calculate_modifier(attacker, attack, options)
          mod = attacker.statblock.ability_modifier(attack.relevant_stat)
          mod -= 5 if options[:great_weapon_master] || options[:sharpshooter]
          mod
        end

        def self.execute_roll(attack, modifier, advantage, disadvantage)
          if advantage && !disadvantage
            attack.dice_roller.roll_with_advantage(20, modifier: modifier)
          elsif disadvantage && !advantage
            attack.dice_roller.roll_with_disadvantage(20, modifier: modifier)
          else
            attack_dice = Dice.new(1, 20, modifier: modifier)
            attack.dice_roller.roll_with_dice(attack_dice)
          end
        end

        def self.determine_advantage_disadvantage(attacker, defender, attack, options)
          adv, dis = parse_initial_options(options)

          adv, dis = apply_attacker_conditions(attacker, adv, dis)
          apply_defender_conditions(defender, attack, adv, dis)
        end

        def self.parse_initial_options(options)
          [options[:advantage] || false, options[:disadvantage] || false]
        end

        def self.apply_attacker_conditions(attacker, adv, dis)
          conditions = attacker.statblock.conditions
          dis = true if conditions.include?(:prone) || conditions.include?(:restrained)
          adv = true if conditions.include?(:hidden)
          [adv, dis]
        end

        def self.apply_defender_conditions(defender, attack, adv, dis)
          conditions = defender.statblock.conditions
          if conditions.include?(:prone)
            attack.range <= 5 ? adv = true : dis = true
          end
          adv = true if conditions.include?(:restrained)
          dis = true if conditions.include?(:hidden)
          [adv, dis]
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
