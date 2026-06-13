# frozen_string_literal: true

require_relative 'helpers/attack_roll_helper'
require_relative 'helpers/damage_roll_helper'
require_relative 'helpers/save_resolution_helper'
require_relative 'mastery_resolver'
require_relative 'attack_result_builder'

module Dnd5e
  module Core
    # Orchestrates the resolution of an attack.
    class AttackResolver
      def initialize(result_builder: nil, logger: nil)
        @result_builder = result_builder || AttackResultBuilder.new(logger: logger)
      end

      def resolve(attacker, defender, attack, **opts)
        if attack.type == :save
          apply_save_attack(attacker, defender, attack, opts)
        else
          apply_standard_attack(attacker, defender, attack, opts)
        end
      end

      private

      def apply_save_attack(attacker, defender, attack, _opts)
        res_data = Helpers::SaveResolutionHelper.resolve(attacker, defender, attack)
        
        details = res_data[:details].merge(hp_and_prof_details(attacker, defender))
        @result_builder.build(attacker: attacker, defender: defender, attack: attack,
                              outcome: res_data[:outcome], details: details)
      end

      def apply_standard_attack(attacker, defender, attack, opts)
        opts[:distance] ||= opts[:combat].grid_distance(attacker, defender) if opts[:combat]
        roll_data = Helpers::AttackRollHelper.roll_attack(attacker, defender, attack, opts)
        roll_data = apply_after_roll_hooks(attacker, defender, attack, roll_data, opts)

        outcome = {
          success: roll_data[:total] >= defender.statblock.armor_class,
          critical: roll_data[:is_crit],
          options: opts
        }

        apply_and_build_result(attacker, defender, attack, roll_data, outcome)
      end

      def apply_after_roll_hooks(attacker, defender, attack, roll_data, options)
        context = { attacker: attacker, defender: defender, attack: attack, options: options, current_value: roll_data }
        roll_data = attacker.feature_manager.apply_hook(:on_after_attack_roll, context, roll_data)
        defender.feature_manager.apply_hook(:on_after_attack_roll, context, roll_data)
        roll_data
      end

      def apply_and_build_result(attacker, defender, attack, roll_data, outcome)
        attacker.statblock.heroic_inspiration = true if roll_data[:is_crit]
        
        dmg_data = calculate_damage(attacker, defender, attack, roll_data, outcome)
        
        if outcome[:success]
          handle_hit_effects(attacker, defender, attack, outcome, dmg_data)
        elsif attack.mastery == :graze
          apply_graze(attacker, defender, attack, dmg_data)
        end

        apply_final_damage(defender, attacker, dmg_data[:damage]) if dmg_data[:damage].positive?

        build_final_result(attacker, defender, attack, roll_data, outcome, dmg_data)
      end

      def calculate_damage(attacker, defender, attack, roll_data, outcome)
        return { damage: 0, rolls: [], modifier: 0 } unless outcome[:success] || attack.mastery == :graze

        opt = outcome[:options]
        mod = Helpers::DamageRollHelper.calculate_modifier(attacker, attack, opt)
        dice = Helpers::DamageRollHelper.calculate_dice(attacker, attack, roll_data[:is_crit], opt)
        
        base_dmg = attack.dice_roller.roll_with_dice(Dice.new(dice.count, dice.sides, modifier: mod))
        base_rolls = attack.dice_roller.dice.rolls.dup

        extra_dmg, extra_rolls = Helpers::DamageRollHelper.roll_extra(attacker, defender, attack, opt)
        
        total_dmg = base_dmg + extra_dmg
        total_dmg = apply_damage_taken_hooks(defender, attacker, attack, total_dmg, opt)

        { damage: total_dmg, rolls: base_rolls + extra_rolls, modifier: mod }
      end

      def handle_hit_effects(attacker, defender, attack, outcome, dmg_data)
        # Trigger on_attack_hit for Maneuvers and other on-hit features
        context = { 
          attacker: attacker, defender: defender, attack: attack,
          options: outcome[:options], combat: outcome[:options][:combat],
          result: dmg_data, dice_roller: attack.dice_roller 
        }
        attacker.feature_manager.execute_hook(:on_attack_hit, context)

        MasteryResolver.apply(attacker, defender, attack, outcome[:options])
      end

      def apply_graze(att, defn, atk, dmg_data)
        opts = { attacker: att, defender: defn, mastery: :graze, success: true }
        att.instance_variable_get(:@combat_context)&.notify_observers(:mastery_used, opts)

        dmg_data[:damage] = [1, att.statblock.ability_modifier(atk.relevant_stat)].max
      end

      def build_final_result(attacker, defender, attack, roll_data, outcome, dmg_data)
        details = {
          attack_roll: roll_data[:total], raw_roll: roll_data[:raw], modifier: roll_data[:modifier],
          is_dead: !defender.statblock.alive?, target_ac: defender.statblock.armor_class,
          rolls: roll_data[:rolls], advantage: roll_data[:advantage],
          disadvantage: roll_data[:disadvantage], is_crit: roll_data[:is_crit],
          damage_rolls: dmg_data[:rolls], damage_modifier: dmg_data[:modifier],
          maneuver: outcome[:options][:maneuver]
        }.merge(hp_and_prof_details(attacker, defender))

        @result_builder.build(attacker: attacker, defender: defender, attack: attack,
                              outcome: outcome.merge(damage: dmg_data[:damage]),
                              details: details)
      end

      def hp_and_prof_details(attacker, defender)
        {
          current_hp: defender.statblock.hit_points,
          max_hp: defender.statblock.max_hp,
          proficiency_bonus: attacker.statblock.proficiency_bonus
        }
      end

      def apply_damage_taken_hooks(defender, attacker, attack, damage, options)
        context = { attacker: attacker, defender: defender, attack: attack, options: options }
        defender.feature_manager.apply_hook(:on_damage_taken, context, damage)
      end

      def apply_final_damage(defender, attacker, damage)
        defender.statblock.take_damage(damage)
        attacker.statblock.record_damage_dealt(damage)
      end
    end
  end
end
