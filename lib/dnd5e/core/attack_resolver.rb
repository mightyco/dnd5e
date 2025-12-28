# frozen_string_literal: true

require_relative 'dice'
require_relative 'attack_result'
require 'logger'

module Dnd5e
  module Core
    # Resolves an attack, applying damage and returning the result.
    class AttackResolver
      # @param logger [Logger] Deprecated: Logger is no longer used in AttackResolver.
      def initialize(logger: nil)
        # Logger dependency removed. Kept in init for backward compatibility but unused.
      end

      # Resolves an attack, applying damage and returning the result.
      #
      # @param attacker [Character] The attacking character.
      # @param defender [Character] The defending character.
      # @param attack [Attack] The attack being performed.
      # @return [AttackResult] The result of the attack.
      def resolve(attacker, defender, attack)
        if attack.type == :save
          resolve_save(attacker, defender, attack)
        else
          resolve_attack_roll(attacker, defender, attack)
        end
      end

      private

      def resolve_attack_roll(attacker, defender, attack)
        return handle_missing_ac(attacker, defender, attack) if defender.statblock.armor_class.nil?

        attack_roll = roll_attack(attacker, attack)
        target_ac = defender.statblock.armor_class
        success = attack_roll >= target_ac
        damage, is_dead = apply_attack_damage(defender, attack, success)

        create_attack_result(
          combat_context: { attacker: attacker, defender: defender, attack: attack },
          outcome: { success: success, damage: damage },
          type: :attack, attack_roll: attack_roll, target_ac: target_ac, is_dead: is_dead
        )
      end

      def resolve_save(attacker, defender, attack)
        dc = calculate_dc(attacker, attack)
        save_roll = roll_save(defender, attack)
        damage, is_dead, attacker_success = apply_save_damage(defender, attack, save_roll, dc)

        create_attack_result(
          combat_context: { attacker: attacker, defender: defender, attack: attack },
          outcome: { success: attacker_success, damage: damage },
          type: :save, save_roll: save_roll, save_dc: dc, is_dead: is_dead
        )
      end

      def handle_missing_ac(attacker, defender, attack)
        # Treat as auto-miss or handle error? For now, return miss with 0 damage.
        create_attack_result(
          combat_context: { attacker: attacker, defender: defender, attack: attack },
          outcome: { success: false, damage: 0 },
          type: :attack, target_ac: nil
        )
      end

      def roll_attack(attacker, attack)
        attack_dice = Dice.new(1, 20, modifier: attacker.statblock.ability_modifier(attack.relevant_stat))
        attack.dice_roller.roll_with_dice(attack_dice)
      end

      def apply_attack_damage(defender, attack, success)
        damage = 0
        if success
          damage = attack.dice_roller.roll_with_dice(attack.damage_dice)
          apply_damage(defender, damage)
        end
        [damage, !defender.statblock.alive?]
      end

      def create_attack_result(params)
        AttackResult.new(**params)
      end

      def calculate_dc(attacker, attack)
        attack.fixed_dc || (8 + attacker.statblock.proficiency_bonus +
                            attacker.statblock.ability_modifier(attack.dc_stat))
      end

      def roll_save(defender, attack)
        save_mod = defender.statblock.save_modifier(attack.save_ability)
        attack.dice_roller.roll_with_dice(Dice.new(1, 20, modifier: save_mod))
      end

      def apply_save_damage(defender, attack, save_roll, difficulty_class)
        full_damage = attack.dice_roller.roll_with_dice(attack.damage_dice)
        save_success = save_roll >= difficulty_class
        attacker_success = !save_success

        damage = calculate_save_damage(attack, full_damage, save_success)
        apply_damage(defender, damage)

        [damage, !defender.statblock.alive?, attacker_success]
      end

      def calculate_save_damage(attack, full_damage, save_success)
        if save_success
          attack.half_damage_on_save ? (full_damage / 2).floor : 0
        else
          full_damage
        end
      end

      def apply_damage(defender, damage)
        return unless damage.positive?

        defender.statblock.take_damage(damage)
      end
    end
  end
end
