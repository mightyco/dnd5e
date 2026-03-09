# frozen_string_literal: true

require_relative '../dice'

module Dnd5e
  module Core
    module Helpers
      # Helper for attack calculations.
      class AttackRollHelper
        def self.roll_attack(attacker, defender, attack, options)
          modifier = calculate_modifier(attacker, attack, options)
          distance = options[:distance] || 5
          adv, dis = determine_advantage_disadvantage(attacker, defender, attack, distance, options)

          total = execute_roll(attack, modifier, adv, dis)
          rolls = attack.dice_roller.dice.rolls
          raw = select_natural_roll(rolls, adv: adv, dis: dis)
          is_crit = raw >= attacker.statblock.crit_threshold

          { total: total, raw: raw, modifier: modifier, is_crit: is_crit,
            rolls: rolls, advantage: adv, disadvantage: dis }
        end

        def self.calculate_modifier(attacker, attack, options)
          mod = attacker.statblock.ability_modifier(attack.relevant_stat)
          context = { attacker: attacker, attack: attack, options: options }
          attacker.feature_manager.apply_modifier_hook(:on_attack_roll, context, mod)
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

        def self.determine_advantage_disadvantage(attacker, defender, attack, distance, options)
          adv, dis = parse_initial_options(options)

          adv, dis = apply_attacker_conditions(attacker, adv, dis)
          adv, dis = apply_defender_conditions(defender, attack, adv, dis)
          adv = true if vexed?(attacker, defender)

          # 2024: Use Heroic Inspiration for Advantage
          if !adv && attacker.statblock.heroic_inspiration
            adv = true
            attacker.statblock.heroic_inspiration = false
          end

          apply_proximity_disadvantage(attack, distance, adv, dis)
        end

        def self.vexed?(attacker, defender)
          return false unless attacker.condition?(:vexing)

          context = attacker.statblock.condition_manager.get_context(:vexing)
          context && context[:target] == defender
        end

        def self.apply_proximity_disadvantage(attack, distance, adv, dis)
          dis = true if attack.range > 5 && distance <= 5
          [adv, dis]
        end

        def self.parse_initial_options(options)
          [options[:advantage] || false, options[:disadvantage] || false]
        end

        def self.apply_attacker_conditions(attacker, adv, dis)
          dis = true if attacker.prone? || attacker.condition?(:restrained) || attacker.condition?(:sapped)
          adv = true if attacker.condition?(:hidden)
          [adv, dis]
        end

        def self.apply_defender_conditions(defender, attack, adv, dis)
          if defender.prone?
            if attack.range <= 5 then adv = true
            else dis = true
            end
          end
          adv = true if defender.condition?(:restrained)
          dis = true if defender.condition?(:hidden)
          [adv, dis]
        end

        def self.critical_hit?(attacker, attack, options)
          rolls = attack.dice_roller.dice&.rolls
          return false unless rolls

          natural_roll = select_natural_roll(rolls, options)
          natural_roll >= attacker.statblock.crit_threshold
        end

        def self.select_natural_roll(rolls, options)
          if options[:adv] || (options[:advantage] && !options[:disadvantage])
            rolls.max
          elsif options[:dis] || (options[:disadvantage] && !options[:advantage])
            rolls.min
          else
            rolls.first
          end
        end
      end
    end
  end
end
