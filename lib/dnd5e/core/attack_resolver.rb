# frozen_string_literal: true

require_relative 'dice'
require_relative 'attack_result_builder'
require_relative 'helpers/attack_roll_helper'
require_relative 'helpers/save_resolution_helper'
require_relative 'helpers/damage_roll_helper'
require 'logger'
require 'ostruct'

module Dnd5e
  module Core
    # Resolves an attack, applying damage and returning the result.
    class AttackResolver
      def initialize(*)
        @result_builder = AttackResultBuilder.new
      end

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
        roll_data = apply_after_roll_hooks(attacker, defender, attack, roll_data, options)

        success = roll_data[:total] >= defender.statblock.armor_class || roll_data[:is_crit]
        apply_and_build_result(attacker, defender, attack, roll_data, { success: success, options: options })
      end

      def apply_after_roll_hooks(attacker, defender, attack, roll_data, options)
        context = { attacker: attacker, defender: defender, attack: attack, options: options }
        attacker.feature_manager.apply_hook(:on_after_attack_roll, context, roll_data)
      end

      def apply_and_build_result(attacker, defender, attack, roll_data, outcome)
        attacker.statblock.heroic_inspiration = true if roll_data[:is_crit]

        dmg_data = apply_attack_damage(attacker, defender, attack, roll_data, outcome)

        handle_hit_or_miss(attacker, defender, attack, outcome, dmg_data)

        build_attack_result(attacker: attacker, defender: defender, attack: attack,
                            roll_data: roll_data, success: outcome[:success],
                            damage: dmg_data[:damage], is_dead: dmg_data[:is_dead],
                            damage_rolls: dmg_data[:rolls], damage_modifier: dmg_data[:modifier])
      end

      def handle_hit_or_miss(attacker, defender, attack, outcome, dmg_data)
        if outcome[:success]
          apply_weapon_mastery(attacker, defender, attack, outcome[:options])
        elsif attack.mastery == :graze
          apply_graze(attacker, defender, attack, dmg_data)
        end
      end

      def apply_graze(attacker, defender, attack, dmg_data)
        damage = [1, attacker.statblock.ability_modifier(attack.relevant_stat)].max
        defender.statblock.take_damage(damage)
        attacker.statblock.record_damage_dealt(damage)
        dmg_data[:damage] = damage
      end

      def apply_weapon_mastery(attacker, defender, attack, options)
        case attack.mastery
        when :vex then attacker.add_condition(:vexing, { target: defender, expiry: :turn_end })
        when :topple then resolve_topple(attacker, defender, attack)
        when :sap then defender.add_condition(:sapped, { expiry: :turn_start })
        when :slow then defender.add_condition(:slowed, { expiry: :turn_start })
        when :push then options[:combat].distance += 10 if options[:combat]
        end
      end

      def resolve_topple(attacker, defender, attack)
        dc = Helpers::SaveResolutionHelper.calculate_dc(attacker, attack)
        save_params = { save_ability: :constitution, dice_roller: attack.dice_roller }
        save_data = Helpers::SaveResolutionHelper.roll_save(defender,
                                                            Struct.new(*save_params.keys).new(*save_params.values))
        defender.add_condition(:prone) if save_data[:total] < dc
      end

      def build_attack_result(params)
        @result_builder.build(attacker: params[:attacker], defender: params[:defender], attack: params[:attack],
                              outcome: { success: params[:success], damage: params[:damage] },
                              details: build_details(params))
      end

      def build_details(params)
        rd = params[:roll_data]
        { attack_roll: rd[:total], raw_roll: rd[:raw], modifier: rd[:modifier], is_dead: params[:is_dead],
          target_ac: params[:defender].statblock.armor_class, rolls: rd[:rolls], advantage: rd[:advantage],
          disadvantage: rd[:disadvantage], is_crit: rd[:is_crit], damage_rolls: params[:damage_rolls],
          damage_modifier: params[:damage_modifier] }
      end

      def resolve_save(attacker, defender, attack)
        res = Helpers::SaveResolutionHelper.resolve(attacker, defender, attack)
        @result_builder.build(attacker: attacker, defender: defender, attack: attack,
                              outcome: res[:outcome], details: res[:details])
      end

      def handle_missing_ac(att, defn, atk)
        @result_builder.build(attacker: att, defender: defn, attack: atk,
                              outcome: { success: false, damage: 0 }, details: { target_ac: nil })
      end

      # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
      def apply_attack_damage(attacker, defender, attack, roll_data, outcome)
        return { damage: 0, is_dead: false, rolls: [], modifier: 0 } unless outcome[:success]

        opt = outcome[:options]
        is_crit = roll_data[:is_crit]
        damage_dice = Helpers::DamageRollHelper.calculate_dice(attacker, attack, is_crit, opt)
        mod = Helpers::DamageRollHelper.calculate_modifier(attacker, attack, opt)
        damage = attack.dice_roller.roll_with_dice(Dice.new(damage_dice.count, damage_dice.sides, modifier: mod))
        rolls = attack.dice_roller.dice.rolls.dup

        extra_dmg, extra_rolls = Helpers::DamageRollHelper.roll_extra(attacker, defender, attack, opt)
        total_dmg = damage + extra_dmg
        defender.statblock.take_damage(total_dmg)
        attacker.statblock.record_damage_dealt(total_dmg) if total_dmg.positive?

        { damage: total_dmg, is_dead: !defender.statblock.alive?, rolls: rolls + extra_rolls, modifier: mod }
      end
      # rubocop:enable Metrics/AbcSize, Metrics/MethodLength
    end
  end
end
