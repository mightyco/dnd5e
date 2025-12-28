# frozen_string_literal: true

require_relative '../dice'

module Dnd5e
  module Core
    module Helpers
      # Helper for resolving saving throws.
      class SaveResolutionHelper
        def self.resolve(attacker, defender, attack)
          dc = calculate_dc(attacker, attack)
          save_roll = roll_save(defender, attack)
          damage, is_dead, attacker_success = apply_save_damage(defender, attack, save_roll, dc)

          {
            outcome: { success: attacker_success, damage: damage },
            details: { type: :save, save_roll: save_roll, save_dc: dc, is_dead: is_dead }
          }
        end

        def self.calculate_dc(attacker, attack)
          attack.fixed_dc || (8 + attacker.statblock.proficiency_bonus +
                              attacker.statblock.ability_modifier(attack.dc_stat))
        end

        def self.roll_save(defender, attack)
          save_mod = defender.statblock.save_modifier(attack.save_ability)
          attack.dice_roller.roll_with_dice(Dice.new(1, 20, modifier: save_mod))
        end

        def self.apply_save_damage(defender, attack, save_roll, difficulty_class)
          full_damage = attack.dice_roller.roll_with_dice(attack.damage_dice)
          save_success = save_roll >= difficulty_class
          attacker_success = !save_success

          damage = calculate_save_damage(attack, full_damage, save_success)
          defender.statblock.take_damage(damage) if damage.positive?

          [damage, !defender.statblock.alive?, attacker_success]
        end

        def self.calculate_save_damage(attack, full_damage, save_success)
          if save_success
            attack.half_damage_on_save ? (full_damage / 2).floor : 0
          else
            full_damage
          end
        end
      end
    end
  end
end
