# frozen_string_literal: true

require_relative 'dice'
require_relative 'attack_result_builder'
require_relative 'helpers/attack_roll_helper'
require_relative 'helpers/save_resolution_helper'
require_relative 'helpers/damage_roll_helper'
require_relative 'mastery_resolver'
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
        return resolve_save_attack(attacker, defender, attack) if attack.type == :save
        return handle_missing_ac(attacker, defender, attack) if defender.statblock.armor_class.nil?

        apply_standard_attack(attacker, defender, attack, opts)
      end

      private

      def apply_standard_attack(attacker, defender, attack, opts)
        opts[:distance] ||= opts[:combat].distance if opts[:combat]
        roll_data = Helpers::AttackRollHelper.roll_attack(attacker, defender, attack, opts)
        roll_data = apply_after_roll_hooks(attacker, defender, attack, roll_data, opts)

        success = roll_data[:total] >= defender.statblock.armor_class || roll_data[:is_crit]
        apply_and_build_result(attacker, defender, attack, roll_data, { success: success, options: opts })
      end

      def resolve_save_attack(attacker, defender, attack)
        res = Helpers::SaveResolutionHelper.resolve(attacker, defender, attack)
        details = res[:details].merge(hp_and_prof_details(attacker, defender))
        @result_builder.build(attacker: attacker, defender: defender, attack: attack,
                              outcome: res[:outcome], details: details)
      end

      def hp_and_prof_details(att, defn)
        { current_hp: defn.statblock.hit_points, max_hp: defn.statblock.calculate_hit_points,
          proficiency_bonus: att.statblock.proficiency_bonus }
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

        details = build_details(roll_data, dmg_data, defender, attacker)
        details[:maneuver] = outcome[:options][:maneuver] if outcome[:options][:maneuver]

        @result_builder.build(attacker: attacker, defender: defender, attack: attack,
                              outcome: { success: outcome[:success], damage: dmg_data[:damage] },
                              details: details)
      end

      def notify_on_hit(attacker, defender, attack, outcome, dmg_data)
        context = { attacker: attacker, defender: defender, attack: attack,
                    combat: outcome[:options][:combat],
                    options: outcome[:options], result: dmg_data, dice_roller: attack.dice_roller }
        attacker.feature_manager.execute_hook(:on_attack_hit, context)
      end

      def handle_hit_or_miss(attacker, defender, attack, outcome, dmg_data)
        if outcome[:success]
          MasteryResolver.apply(attacker, defender, attack, outcome[:options])
        elsif attack.mastery == :graze
          apply_graze(attacker, defender, attack, dmg_data)
        end
      end

      def apply_graze(att, defn, atk, dmg_data)
        dmg_data[:damage] = [1, att.statblock.ability_modifier(atk.relevant_stat)].max
        defn.statblock.take_damage(dmg_data[:damage])
        att.statblock.record_damage_dealt(dmg_data[:damage])
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
        dice = Helpers::DamageRollHelper.calculate_dice(attacker, attack, roll_data[:is_crit], opt)
        damage = attack.dice_roller.roll_with_dice(Dice.new(dice.count, dice.sides, modifier: mod))
        rolls = attack.dice_roller.dice.rolls.dup

        apply_additional_damage(damage, rolls, { attacker: attacker, defender: defender, attack: attack, options: opt },
                                mod)
      end

      def apply_additional_damage(base_damage, base_rolls, ctx, mod)
        extra_dmg, extra_rolls = Helpers::DamageRollHelper.roll_extra(ctx[:attacker], ctx[:defender],
                                                                      ctx[:attack], ctx[:options])
        total_dmg = base_damage + extra_dmg
        ctx[:defender].statblock.take_damage(total_dmg)
        ctx[:attacker].statblock.record_damage_dealt(total_dmg) if total_dmg.positive?
        { damage: total_dmg, rolls: base_rolls + extra_rolls, modifier: mod }
      end
    end
  end
end
