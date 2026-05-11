# frozen_string_literal: true

require_relative 'helpers/save_resolution_helper'

module Dnd5e
  module Core
    # Resolves weapon mastery effects.
    class MasteryResolver
      def self.apply(attacker, defender, attack, options = {})
        combat = options[:combat]
        case attack.mastery
        when :vex then apply_vex(attacker, defender, combat)
        when :topple then resolve_topple(attacker, defender, attack, combat)
        when :push then resolve_push(attacker, defender, combat)
        when :slow then apply_slow(attacker, defender, combat)
        when :nick then notify_mastery(combat, attacker, defender, :nick, true)
        when :cleave then notify_mastery(combat, attacker, defender, :cleave, true)
        end
      end

      def self.apply_vex(attacker, defender, combat)
        attacker.add_condition(:vexing, { target: defender, expiry: :turn_end })
        notify_mastery(combat, attacker, defender, :vex, true)
      end

      def self.apply_slow(attacker, defender, combat)
        defender.add_condition(:slowed, { expiry: :turn_start })
        notify_mastery(combat, attacker, defender, :slow, true)
      end

      def self.notify_mastery(combat, attacker, defender, mastery, success)
        return unless combat

        combat.notify_observers(:mastery_used, {
                                  attacker: attacker, defender: defender,
                                  mastery: mastery, success: success
                                })
      end

      # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
      def self.resolve_push(attacker, defender, combat)
        return unless combat

        att_pos = combat.grid.find_position(attacker)
        defn_pos = combat.grid.find_position(defender)
        return unless att_pos && defn_pos

        # 2024: Push works on Large or smaller
        unless %i[tiny small medium large].include?(defender.statblock.size)
          notify_mastery(combat, attacker, defender, :push, false)
          return
        end

        # Calculate direction vector
        dx = defn_pos.x - att_pos.x
        dy = defn_pos.y - att_pos.y

        mag = Math.sqrt((dx**2) + (dy**2))
        return if mag.zero?

        push_x = ((dx / mag) * 10).round / 5 * 5
        push_y = ((dy / mag) * 10).round / 5 * 5

        new_pos = Point2D.new(defn_pos.x + push_x, defn_pos.y + push_y)
        combat.grid.move(defender, new_pos)
        notify_mastery(combat, attacker, defender, :push, true)
      end
      # rubocop:enable Metrics/AbcSize, Metrics/MethodLength

      def self.resolve_topple(att, defn, atk, combat)
        dc = Helpers::SaveResolutionHelper.calculate_dc(att, atk)
        struct = Struct.new(:save_ability, :dice_roller).new(:dexterity, atk.dice_roller)
        save_data = Helpers::SaveResolutionHelper.roll_save(defn, struct)
        success = save_data[:total] < dc
        defn.add_condition(:prone) if success
        notify_mastery(combat, att, defn, :topple, success)
      end
    end
  end
end
