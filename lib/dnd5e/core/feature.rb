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

      # Called when a saving throw is being calculated.
      # @param context [Hash] Context including :attacker, :defender, :attack, :modifier.
      # @return [Integer] The modification to the save modifier.
      def on_save_roll(_context)
        0
      end
    end
  end
end
