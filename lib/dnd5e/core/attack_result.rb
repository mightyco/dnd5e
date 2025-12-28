# frozen_string_literal: true

module Dnd5e
  module Core
    # Stores the result of an attack resolution.
    class AttackResult
      attr_reader :attacker, :defender, :attack, :success, :damage, :type,
                  :attack_roll, :raw_roll, :modifier, :target_ac,
                  :save_roll, :save_dc, :is_dead, :rolls, :advantage, :disadvantage,
                  :damage_rolls, :damage_modifier

      # Initializes a new AttackResult.
      #
      # @param combat_context [Hash] Context of the attack (attacker, defender, attack).
      # @param outcome [Hash] Result of the attack (success, damage).
      # @param type [Symbol] :attack or :save.
      # @param details [Hash] Additional details (attack_roll, target_ac, etc.)
      def initialize(combat_context:, outcome:, type:, **details)
        @attacker = combat_context[:attacker]
        @defender = combat_context[:defender]
        @attack = combat_context[:attack]
        @success = outcome[:success]
        @damage = outcome[:damage]
        @type = type
        assign_details(details)
      end

      private

      def assign_details(details)
        assign_roll_details(details)
        assign_save_details(details)
        assign_damage_details(details)
        @is_dead = details[:is_dead] || false
      end

      def assign_roll_details(details)
        @attack_roll = details[:attack_roll]
        @raw_roll = details[:raw_roll]
        @modifier = details[:modifier]
        @rolls = details[:rolls] || []
        @advantage = details[:advantage] || false
        @disadvantage = details[:disadvantage] || false
      end

      def assign_save_details(details)
        @target_ac = details[:target_ac]
        @save_roll = details[:save_roll]
        @save_dc = details[:save_dc]
      end

      def assign_damage_details(details)
        @damage_rolls = details[:damage_rolls] || []
        @damage_modifier = details[:damage_modifier] || 0
      end
    end
  end
end
