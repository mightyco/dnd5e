# frozen_string_literal: true

require_relative 'dice'
require_relative 'attack_result_builder'
require_relative 'helpers/attack_roll_helper'
require_relative 'helpers/save_resolution_helper'
require_relative 'helpers/damage_roll_helper'
require 'logger'

module Dnd5e
  module Core
    # Resolves an attack, applying damage and returning the result.
    class AttackResolver
      def initialize(*)
        @result_builder = AttackResultBuilder.new
      end

      # Resolves an attack, applying damage and returning the result.
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

        options[:distance] ||= options[:combat].distance if options[:combat]
        roll_data = Helpers::AttackRollHelper.roll_attack(attacker, defender, attack, options)
        success = roll_data[:total] >= defender.statblock.armor_class || roll_data[:is_crit]

        apply_and_build_result(attacker, defender, attack, roll_data, { success: success, options: options })
      end

      def apply_and_build_result(attacker, defender, attack, roll_data, outcome)
        dmg_data = apply_attack_damage(defender, attack, outcome[:success],
                                       is_crit: roll_data[:is_crit],
                                       attacker: attacker, **outcome[:options])

        build_attack_result(attacker: attacker, defender: defender, attack: attack,
                            roll_data: roll_data, success: outcome[:success],
                            damage: dmg_data[:damage], is_dead: dmg_data[:is_dead],
                            damage_rolls: dmg_data[:rolls], damage_modifier: dmg_data[:modifier])
      end

      def build_attack_result(params)
        @result_builder.build(attacker: params[:attacker], defender: params[:defender], attack: params[:attack],
                              outcome: { success: params[:success], damage: params[:damage] },
                              details: build_details(params))
      end

      def build_details(params)
        details = build_basic_details(params)
        details.merge(build_damage_details(params))
      end

      def build_basic_details(params)
        {
          attack_roll: params[:roll_data][:total], raw_roll: params[:roll_data][:raw],
          modifier: params[:roll_data][:modifier], is_dead: params[:is_dead],
          target_ac: params[:defender].statblock.armor_class,
          rolls: params[:roll_data][:rolls], advantage: params[:roll_data][:advantage],
          disadvantage: params[:roll_data][:disadvantage]
        }
      end

      def build_damage_details(params)
        { damage_rolls: params[:damage_rolls], damage_modifier: params[:damage_modifier] }
      end

      def resolve_save(attacker, defender, attack)
        result = Helpers::SaveResolutionHelper.resolve(attacker, defender, attack)
        @result_builder.build(attacker: attacker, defender: defender, attack: attack,
                              outcome: result[:outcome], details: result[:details])
      end

      def handle_missing_ac(attacker, defender, attack)
        @result_builder.build(attacker: attacker, defender: defender, attack: attack,
                              outcome: { success: false, damage: 0 },
                              details: { target_ac: nil })
      end

      def apply_attack_damage(defender, attack, success, is_crit: false, **options)
        damage = 0
        rolls = []
        modifier = 0
        damage, rolls, modifier = roll_damage(defender, attack, is_crit, options) if success
        { damage: damage, is_dead: !defender.statblock.alive?, rolls: rolls, modifier: modifier }
      end

      def roll_damage(defender, attack, is_crit, options)
        attacker = options[:attacker]
        damage_dice = Helpers::DamageRollHelper.calculate_dice(attacker, attack, is_crit, options)
        damage = attack.dice_roller.roll_with_dice(damage_dice)
        rolls = attack.dice_roller.dice.rolls.dup

        extra_dmg, extra_rolls = Helpers::DamageRollHelper.roll_extra(attacker, defender, attack, options)
        apply_damage(defender, damage + extra_dmg)
        [damage + extra_dmg, rolls + extra_rolls, damage_dice.modifier]
      end

      def apply_damage(defender, damage)
        defender.statblock.take_damage(damage) if damage.positive?
      end
    end
  end
end
