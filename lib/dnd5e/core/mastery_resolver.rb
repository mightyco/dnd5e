# frozen_string_literal: true

require_relative 'helpers/save_resolution_helper'

module Dnd5e
  module Core
    # Resolves weapon mastery effects.
    class MasteryResolver
      def self.apply(attacker, defender, attack, options)
        case attack.mastery
        when :vex then attacker.add_condition(:vexing, { target: defender, expiry: :turn_end })
        when :topple then resolve_topple(attacker, defender, attack)
        when :sap then defender.add_condition(:sapped, { expiry: :turn_start })
        when :slow then defender.add_condition(:slowed, { expiry: :turn_start })
        when :push then options[:combat].distance += 10 if options[:combat]
        end
      end

      def self.resolve_topple(att, defn, atk)
        dc = Helpers::SaveResolutionHelper.calculate_dc(att, atk)
        struct = Struct.new(:save_ability, :dice_roller).new(:dexterity, atk.dice_roller)
        defn.add_condition(:prone) if Helpers::SaveResolutionHelper.roll_save(defn, struct)[:total] < dc
      end
    end
  end
end
