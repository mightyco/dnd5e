# frozen_string_literal: true

require_relative 'helpers/save_resolution_helper'

module Dnd5e
  module Core
    # Resolves weapon mastery effects.
    class MasteryResolver
      def self.apply(attacker, defender, attack, options = {})
        case attack.mastery
        when :vex then attacker.add_condition(:vexing, { target: defender, expiry: :turn_end })
        when :topple then resolve_topple(attacker, defender, attack)
        when :push then resolve_push(attacker, defender, options[:combat])
        when :slow then defender.add_condition(:slowed, { expiry: :turn_start })
        end
      end

      # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
      def self.resolve_push(attacker, defender, combat)
        return unless combat

        att_pos = combat.grid.find_position(attacker)
        defn_pos = combat.grid.find_position(defender)
        return unless att_pos && defn_pos

        # Calculate direction vector
        dx = defn_pos.x - att_pos.x
        dy = defn_pos.y - att_pos.y

        # Normalize to 5ft steps (approx)
        mag = Math.sqrt((dx**2) + (dy**2))
        return if mag.zero?

        push_x = ((dx / mag) * 10).round / 5 * 5
        push_y = ((dy / mag) * 10).round / 5 * 5

        new_pos = Point2D.new(defn_pos.x + push_x, defn_pos.y + push_y)
        combat.grid.move(defender, new_pos)
      end
      # rubocop:enable Metrics/AbcSize, Metrics/MethodLength

      def self.resolve_topple(att, defn, atk)
        dc = Helpers::SaveResolutionHelper.calculate_dc(att, atk)
        struct = Struct.new(:save_ability, :dice_roller).new(:dexterity, atk.dice_roller)
        defn.add_condition(:prone) if Helpers::SaveResolutionHelper.roll_save(defn, struct)[:total] < dc
      end
    end
  end
end
