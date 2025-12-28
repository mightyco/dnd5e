# frozen_string_literal: true

require_relative 'dice'
require_relative 'attack_result'
require 'logger'

module Dnd5e
  module Core
    # Resolves an attack, applying damage and returning the result.
    class AttackResolver
      # @param logger [Logger] Deprecated: Logger is no longer used in AttackResolver.
      def initialize(logger: nil); end

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

        attack_roll = roll_attack(attacker, attack, options)
        target_ac = defender.statblock.armor_class
        is_crit = check_critical(attack, options, attack_roll)
        success = attack_roll >= target_ac || is_crit
        damage, is_dead = apply_attack_damage(defender, attack, success, is_crit: is_crit)

        build_attack_result(attacker, defender, attack,
                            outcome: { success: success, damage: damage },
                            details: { attack_roll: attack_roll, target_ac: target_ac, is_dead: is_dead })
      end

      def check_critical(attack, options, attack_roll)
        return false unless attack.dice_roller.dice && attack.dice_roller.dice.rolls

        natural_roll = if options[:advantage]
                         attack.dice_roller.dice.rolls.max
                       elsif options[:disadvantage]
                         attack.dice_roller.dice.rolls.min
                       else
                         attack.dice_roller.dice.rolls.first
                       end
        natural_roll == 20
      end

      def resolve_save(attacker, defender, attack)
        dc = calculate_dc(attacker, attack)
        save_roll = roll_save(defender, attack)
        damage, is_dead, attacker_success = apply_save_damage(defender, attack, save_roll, dc)

        build_attack_result(attacker, defender, attack,
                            outcome: { success: attacker_success, damage: damage },
                            details: { type: :save, save_roll: save_roll, save_dc: dc, is_dead: is_dead })
      end

      def handle_missing_ac(attacker, defender, attack)
        # Treat as auto-miss or handle error? For now, return miss with 0 damage.
        build_attack_result(attacker, defender, attack,
                            outcome: { success: false, damage: 0 },
                            details: { target_ac: nil })
      end

      def roll_attack(attacker, attack, options)
        modifier = attacker.statblock.ability_modifier(attack.relevant_stat)

        if options[:advantage]
          attack.dice_roller.roll_with_advantage(20, modifier: modifier)
        elsif options[:disadvantage]
          attack.dice_roller.roll_with_disadvantage(20, modifier: modifier)
        else
          attack_dice = Dice.new(1, 20, modifier: modifier)
          attack.dice_roller.roll_with_dice(attack_dice)
        end
      end

      def apply_attack_damage(defender, attack, success, is_crit: false)
        damage = 0
        if success
          damage_dice = calculate_damage_dice(attack, is_crit)
          damage = attack.dice_roller.roll_with_dice(damage_dice)
          apply_damage(defender, damage)
        end
        [damage, !defender.statblock.alive?]
      end

      def calculate_damage_dice(attack, is_crit)
        if is_crit
          Dice.new(attack.damage_dice.count * 2, attack.damage_dice.sides,
                   modifier: attack.damage_dice.modifier)
        else
          attack.damage_dice
        end
      end

      def build_attack_result(attacker, defender, attack, outcome:, details:)
        create_attack_result(
          combat_context: { attacker: attacker, defender: defender, attack: attack },
          outcome: outcome,
          type: :attack,
          **details
        )
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
