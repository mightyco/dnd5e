# frozen_string_literal: true

require_relative '../dice'

module Dnd5e
  module Core
    module Helpers
      # Helper for attack calculations.
      class AttackRollHelper
        def self.roll_attack(attacker, defender, attack, options)
          modifier = calculate_modifier(attacker, attack, options)
          distance = options[:distance] || 5 # Default to 5 if not provided
          adv, dis = determine_advantage_disadvantage(attacker, defender, attack, distance, options)

          total = execute_roll(attack, modifier, adv, dis)
          rolls = attack.dice_roller.dice.rolls
          raw = select_natural_roll(rolls, adv: adv, dis: dis)
          is_crit = raw == 20 # Basic 20 for now. Could be improved later for 19-20.

          { total: total, raw: raw, modifier: modifier, is_crit: is_crit,
            rolls: rolls, advantage: adv, disadvantage: dis }
        end

        def self.calculate_modifier(attacker, attack, options)
          mod = attacker.statblock.ability_modifier(attack.relevant_stat)

          # Use feature hooks instead of hardcoded logic
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
          apply_proximity_disadvantage(attack, distance, adv, dis)
        end

        def self.apply_proximity_disadvantage(attack, distance, adv, dis)
          # Ranged attacks have disadvantage if an enemy is within 5 feet
          dis = true if attack.range > 5 && distance <= 5
          [adv, dis]
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

          # We don't have the context of the defender here to re-calculate conditions
          # But critical_hit? is usually called after roll_attack which sets the dice rolls.
          # If advantage was determined by conditions, we should ideally know that here.
          # For now, we rely on the options passed in.
          natural_roll = select_natural_roll(rolls, options)
          natural_roll == 20
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
