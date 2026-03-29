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

      def resolve(attacker, defender, attack, **opts)
        return resolve_attack_roll(attacker, defender, attack, opts) unless attack.type == :save

        res = Helpers::SaveResolutionHelper.resolve(attacker, defender, attack)
        details = res[:details].merge(hp_and_prof_details(attacker, defender))
        @result_builder.build(attacker: attacker, defender: defender, attack: attack,
                              outcome: res[:outcome], details: details)
      end

      private

      def hp_and_prof_details(att, defn)
        { current_hp: defn.statblock.hit_points, max_hp: defn.statblock.calculate_hit_points,
          proficiency_bonus: att.statblock.proficiency_bonus }
      end

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
        notify_on_hit(attacker, defender, attack, outcome, dmg_data) if outcome[:success]

        @result_builder.build(attacker: attacker, defender: defender, attack: attack,
                              outcome: { success: outcome[:success], damage: dmg_data[:damage] },
                              details: build_details(roll_data, dmg_data, defender, attacker))
      end

      def notify_on_hit(attacker, defender, attack, outcome, dmg_data)
        context = { attacker: attacker, defender: defender, attack: attack,
                    options: outcome[:options], result: dmg_data, dice_roller: attack.dice_roller }
        attacker.feature_manager.execute_hook(:on_attack_hit, context)
      end

      def handle_hit_or_miss(attacker, defender, attack, outcome, dmg_data)
        if outcome[:success]
          apply_weapon_mastery(attacker, defender, attack, outcome[:options])
        elsif attack.mastery == :graze
          apply_graze(attacker, defender, attack, dmg_data)
        end
      end

      def apply_graze(att, defn, atk, dmg_data)
        dmg_data[:damage] = [1, att.statblock.ability_modifier(atk.relevant_stat)].max
        defn.statblock.take_damage(dmg_data[:damage])
        att.statblock.record_damage_dealt(dmg_data[:damage])
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

      def resolve_topple(att, defn, atk)
        dc = Helpers::SaveResolutionHelper.calculate_dc(att, atk)
        struct = Struct.new(:save_ability, :dice_roller).new(:constitution, atk.dice_roller)
        defn.add_condition(:prone) if Helpers::SaveResolutionHelper.roll_save(defn, struct)[:total] < dc
      end

      def build_details(roll_data, dmg_data, defender, attacker)
        rd = roll_data
        { attack_roll: rd[:total], raw_roll: rd[:raw], modifier: rd[:modifier], is_dead: !defender.statblock.alive?,
          target_ac: defender.statblock.armor_class, rolls: rd[:rolls], advantage: rd[:advantage],
          disadvantage: rd[:disadvantage], is_crit: rd[:is_crit], damage_rolls: dmg_data[:rolls],
          damage_modifier: dmg_data[:modifier] }.merge(hp_and_prof_details(attacker, defender))
      end

      def handle_missing_ac(att, defn, atk)
        @result_builder.build(attacker: att, defender: defn, attack: atk,
                              outcome: { success: false, damage: 0 }, details: { target_ac: nil })
      end

      def apply_attack_damage(attacker, defender, attack, roll_data, outcome)
        return { damage: 0, rolls: [], modifier: 0 } unless outcome[:success]

        opt = outcome[:options]
        mod = Helpers::DamageRollHelper.calculate_modifier(attacker, attack, opt)
        damage, rolls = calculate_base_damage(attacker, attack, roll_data[:is_crit], opt, mod)

        ctx = { attacker: attacker, defender: defender, attack: attack, options: opt }
        final_dmg, final_rolls = apply_additional_damage(damage, rolls, ctx)

        { damage: final_dmg, rolls: final_rolls, modifier: mod }
      end

      def calculate_base_damage(attacker, attack, is_crit, options, mod)
        dice = Helpers::DamageRollHelper.calculate_dice(attacker, attack, is_crit, options)
        [attack.dice_roller.roll_with_dice(Dice.new(dice.count, dice.sides, modifier: mod)),
         attack.dice_roller.dice.rolls.dup]
      end

      def apply_additional_damage(base_damage, base_rolls, ctx)
        extra_dmg, extra_rolls = Helpers::DamageRollHelper.roll_extra(ctx[:attacker], ctx[:defender],
                                                                      ctx[:attack], ctx[:options])
        total_dmg = base_damage + extra_dmg
        ctx[:defender].statblock.take_damage(total_dmg)
        ctx[:attacker].statblock.record_damage_dealt(total_dmg) if total_dmg.positive?
        [total_dmg, base_rolls + extra_rolls]
      end
    end
  end
end
