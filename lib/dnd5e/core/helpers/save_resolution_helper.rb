# frozen_string_literal: true

require_relative '../dice'

module Dnd5e
  module Core
    module Helpers
      # Helper for resolving saving throws.
      class SaveResolutionHelper
        def self.resolve(attacker, defender, attack)
          difficulty_class = calculate_dc(attacker, attack)
          save_data = roll_save(defender, attack)
          dmg_data = apply_save_damage(attacker, defender, attack,
                                       save_data[:total], difficulty_class)

          build_result(dmg_data, save_data, difficulty_class)
        end

        def self.build_result(dmg_data, save_data, difficulty_class)
          {
            outcome: { success: dmg_data[:attacker_success], damage: dmg_data[:damage] },
            details: {
              type: :save, save_roll: save_data[:total], raw_roll: save_data[:raw],
              modifier: save_data[:modifier], save_dc: difficulty_class,
              is_dead: dmg_data[:is_dead], damage_rolls: dmg_data[:rolls],
              damage_modifier: dmg_data[:modifier]
            }
          }
        end

        def self.calculate_dc(attacker, attack)
          attack.fixed_dc || (8 + attacker.statblock.proficiency_bonus +
                              attacker.statblock.ability_modifier(attack.dc_stat))
        end

        def self.roll_save(defender, attack)
          save_mod = defender.statblock.save_modifier(attack.save_ability)
          total = attack.dice_roller.roll_with_dice(Dice.new(1, 20, modifier: save_mod))
          raw = attack.dice_roller.dice.rolls.first
          { total: total, raw: raw, modifier: save_mod }
        end

        def self.apply_save_damage(attacker, defender, attack, save_roll, difficulty_class)
          base_dice = attack.damage_dice_for(attacker.statblock.level)
          full_damage = attack.dice_roller.roll_with_dice(base_dice)
          save_success = save_roll >= difficulty_class

          attacker_success = !save_success
          damage = calculate_save_damage(attack, full_damage, save_success)

          # Apply defender feature hooks (e.g., Evasion)
          context = { attacker: attacker, defender: defender, attack: attack,
                      damage: damage, save_success: save_success }
          damage = defender.feature_manager.apply_hook(:on_damage_taken, context, damage)

          defender.statblock.take_damage(damage) if damage.positive?

          build_save_damage_data(damage, defender, attacker_success, attack, base_dice)
        end

        def self.build_save_damage_data(damage, defender, success, attack, dice)
          {
            damage: damage, is_dead: !defender.statblock.alive?,
            attacker_success: success, rolls: attack.dice_roller.dice.rolls,
            modifier: dice.modifier
          }
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
