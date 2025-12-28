# frozen_string_literal: true

module Dnd5e
  module Core
    # Base class for character features, feats, and traits.
    # Features can hook into various game events to modify behavior.
    class Feature
      attr_reader :name

      def initialize(name:)
        @name = name
      end

      # Called when an attack roll is being calculated.
      # @param context [Hash] Context including :attacker, :defender, :attack, :modifier, :options.
      # @return [Integer] The modification to the attack roll modifier.
      def on_attack_roll(_context)
        0
      end

      # Called when damage dice are being calculated.
      # @param context [Hash] Context including :attacker, :defender, :attack, :dice, :options.
      # @return [Dice, nil] A new Dice object to replace the current ones, or nil.
      def on_damage_calculation(_context)
        nil
      end

      # Called to add extra damage dice (e.g. Sneak Attack, Smite).
      # @param context [Hash] Context including :attacker, :defender, :attack, :options.
      # @return [Array<Dice>] An array of extra dice to roll and add to damage.
      def extra_damage_dice(_context)
        []
      end

      # Called when a saving throw is being calculated.
      # @param context [Hash] Context including :attacker, :defender, :attack, :modifier.
      # @return [Integer] The modification to the save modifier.
      def on_save_roll(_context)
        0
      end

      # Called when damage is about to be applied to the character.
      # @param context [Hash] Context including :attacker, :defender, :attack, :damage, :outcome.
      # @return [Integer, nil] The new damage value, or nil to keep current.
      def on_damage_taken(_context)
        nil
      end
    end
  end
end
