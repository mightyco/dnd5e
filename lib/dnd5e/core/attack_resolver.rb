# frozen_string_literal: true

require_relative 'dice'
require_relative 'attack_result_builder'
require_relative 'helpers/attack_roll_helper'
require_relative 'helpers/save_resolution_helper'
require 'logger'

module Dnd5e
  module Core
    # Resolves an attack, applying damage and returning the result.
    class AttackResolver
      # @param logger [Logger] Deprecated: Logger is no longer used in AttackResolver.
      def initialize(*)
        @result_builder = AttackResultBuilder.new
        # Logger kept for backward compatibility signature but unused
      end

      # Resolves an attack, applying damage and returning the result.
      #
      # @param attacker [Character] The attacking character.
      # @param defender [Character] The defending character.
      # @param attack [Attack] The attack being performed.
      # @param options [Hash] Optional flags (advantage, disadvantage).
      # @return [AttackResult] The result of the attack.
      def resolve(attacker, defender, attack, **options)
        if attack.type == :save
          resolve_save(attacker, defender, attack)
        else
          resolve_attack_roll(attacker, defender, attack, options)
        end
      end

      private

      def resolve_attack_roll(attacker, defender, attack, options)
        return handle_missing_ac(attacker, defender, attack) if defender.statblock.armor_class.nil?

        attack_roll = Helpers::AttackRollHelper.roll_attack(attacker, defender, attack, options)
        target_ac = defender.statblock.armor_class
        is_crit = Helpers::AttackRollHelper.critical_hit?(attack, options)
        success = attack_roll >= target_ac || is_crit
        damage, is_dead = apply_attack_damage(defender, attack, success, is_crit: is_crit, **options)

        @result_builder.build(attacker: attacker, defender: defender, attack: attack,
                              outcome: { success: success, damage: damage },
                              details: { attack_roll: attack_roll, target_ac: target_ac, is_dead: is_dead })
      end

      def resolve_save(attacker, defender, attack)
        result = Helpers::SaveResolutionHelper.resolve(attacker, defender, attack)
        @result_builder.build(attacker: attacker, defender: defender, attack: attack,
                              outcome: result[:outcome], details: result[:details])
      end

      def handle_missing_ac(attacker, defender, attack)
        # Treat as auto-miss or handle error? For now, return miss with 0 damage.
        @result_builder.build(attacker: attacker, defender: defender, attack: attack,
                              outcome: { success: false, damage: 0 },
                              details: { target_ac: nil })
      end

      def apply_attack_damage(defender, attack, success, is_crit: false, **options)
        damage = 0
        if success
          damage_dice = calculate_damage_dice(attack, is_crit, options)
          damage = attack.dice_roller.roll_with_dice(damage_dice)
          apply_damage(defender, damage)
        end
        [damage, !defender.statblock.alive?]
      end

      def calculate_damage_dice(attack, is_crit, options)
        modifier = attack.damage_dice.modifier
        modifier += 10 if options[:great_weapon_master] || options[:sharpshooter]

        if is_crit
          Dice.new(attack.damage_dice.count * 2, attack.damage_dice.sides,
                   modifier: modifier)
        else
          Dice.new(attack.damage_dice.count, attack.damage_dice.sides,
                   modifier: modifier)
        end
      end

      def apply_damage(defender, damage)
        return unless damage.positive?

        defender.statblock.take_damage(damage)
      end
    end
  end
end
