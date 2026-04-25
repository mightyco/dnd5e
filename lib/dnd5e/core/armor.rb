# frozen_string_literal: true

module Dnd5e
  module Core
    # Represents a piece of armor or shield with AC and other properties.
    class Armor
      attr_reader :name, :base_ac, :type, :max_dex_bonus, :stealth_disadvantage, :magic_bonus

      TYPES = %i[light medium heavy shield].freeze

      # @param name [String] Name of the armor (e.g., "Chain Mail")
      # @param base_ac [Integer] Base AC value
      # @param type [Symbol] :light, :medium, :heavy, or :shield
      # @param max_dex_bonus [Integer, nil] Maximum Dex modifier to apply (nil for unlimited, 0 for none)
      # @param stealth_disadvantage [Boolean] Whether armor imposes stealth disadvantage
      # rubocop:disable Metrics/ParameterLists
      def initialize(name:, base_ac:, type:, max_dex_bonus: nil, stealth_disadvantage: false, magic_bonus: 0)
        raise ArgumentError, 'Invalid armor type' unless TYPES.include?(type)

        @name = name
        @base_ac = base_ac
        @type = type
        @max_dex_bonus = max_dex_bonus
        @stealth_disadvantage = stealth_disadvantage
        @magic_bonus = magic_bonus
      end

      def calculate_ac(dex_modifier)
        ac = @base_ac + @magic_bonus
        return ac if @type == :shield # Shields handled separately usually, but for base logic

        # Heavy armor rule: Dexterity modifier doesn't affect AC (neither bonus nor penalty)
        return ac if @type == :heavy

        bonus = dex_modifier
        bonus = [dex_modifier, @max_dex_bonus].min if @max_dex_bonus

        ac + bonus
      end
    end
  end
end
# rubocop:enable Metrics/ParameterLists
