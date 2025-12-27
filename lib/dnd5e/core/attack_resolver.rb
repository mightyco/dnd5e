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
        if defender.statblock.armor_class.nil?
          # Treat as auto-miss or handle error? For now, return miss with 0 damage.
          return AttackResult.new(
            attacker: attacker, defender: defender, attack: attack,
            success: false, damage: 0, type: :attack,
            target_ac: nil
          )
        end

        attack_dice = Dice.new(1, 20, modifier: attacker.statblock.ability_modifier(attack.relevant_stat))
        attack_roll = attack.dice_roller.roll_with_dice(attack_dice)

        target_ac = defender.statblock.armor_class
        success = attack_roll >= target_ac

        damage = 0
        is_dead = false

        if success
          damage = attack.dice_roller.roll_with_dice(attack.damage_dice)
          defender.statblock.take_damage(damage)
          is_dead = !defender.statblock.is_alive?
        end

        AttackResult.new(
          attacker: attacker, defender: defender, attack: attack,
          success: success, damage: damage, type: :attack,
          attack_roll: attack_roll, target_ac: target_ac, is_dead: is_dead
        )
      end

      def resolve_save(attacker, defender, attack)
        dc = attack.fixed_dc || 8 + attacker.statblock.proficiency_bonus + attacker.statblock.ability_modifier(attack.dc_stat)

        save_mod = defender.statblock.save_modifier(attack.save_ability)
        save_roll = attack.dice_roller.roll_with_dice(Dice.new(1, 20, modifier: save_mod))

        full_damage = attack.dice_roller.roll_with_dice(attack.damage_dice)

        # Save Success: Roll >= DC
        save_success = save_roll >= dc

        # Attacker "success" (dealing full effect) happens if save fails.
        attacker_success = !save_success
        damage = if save_success
                   attack.half_damage_on_save ? (full_damage / 2).floor : 0
                 else
                   full_damage
                 end

        is_dead = false
        if damage.positive?
          defender.statblock.take_damage(damage)
          is_dead = !defender.statblock.is_alive?
        end

        AttackResult.new(
          attacker: attacker, defender: defender, attack: attack,
          success: attacker_success, damage: damage, type: :save,
          save_roll: save_roll, save_dc: dc, is_dead: is_dead
        )
      end
    end
  end
end
