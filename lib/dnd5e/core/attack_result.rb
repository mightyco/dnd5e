# frozen_string_literal: true

module Dnd5e
  module Core
    # Represents the result of an attack or action resolution.
    class AttackResult
      attr_reader :attacker, :defender, :attack, :success, :damage, :type,
                  :attack_roll, :target_ac, :save_roll, :save_dc, :is_dead

      # @param attacker [Character] The attacker.
      # @param defender [Character] The defender.
      # @param attack [Attack] The attack used.
      # @param success [Boolean] Whether the attack hit or save failed (favorable for attacker).
      # @param damage [Integer] Damage dealt.
      # @param type [Symbol] :attack or :save.
      # @param attack_roll [Integer, nil] The attack roll total (if applicable).
      # @param target_ac [Integer, nil] The target's AC (if applicable).
      # @param save_roll [Integer, nil] The save roll total (if applicable).
      # @param save_dc [Integer, nil] The save DC (if applicable).
      # @param is_dead [Boolean] Whether the defender died from this attack.
      def initialize(attacker:, defender:, attack:, success:, damage:, type:,
                     attack_roll: nil, target_ac: nil, save_roll: nil, save_dc: nil, is_dead: false)
        @attacker = attacker
        @defender = defender
        @attack = attack
        @success = success
        @damage = damage
        @type = type
        @attack_roll = attack_roll
        @target_ac = target_ac
        @save_roll = save_roll
        @save_dc = save_dc
        @is_dead = is_dead
      end

      def hit?
        @success
      end
    end
  end
end
