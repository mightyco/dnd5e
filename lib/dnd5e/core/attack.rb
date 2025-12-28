# frozen_string_literal: true

require_relative 'dice'
require_relative 'dice_roller'

module Dnd5e
  module Core
    # Represents an attack action available to a combatant.
    class Attack
      attr_reader :name, :damage_dice, :relevant_stat, :dice_roller, :type, :save_ability, :half_damage_on_save,
                  :fixed_dc, :dc_stat, :range

      # Initializes a new Attack.
      #
      # @param name [String] The name of the attack.
      # @param damage_dice [Dice] The dice to roll for damage.
      # @param relevant_stat [Symbol] The stat used for the attack roll (e.g., :strength).
      # @param dice_roller [DiceRoller] The dice roller to use.
      # @param type [Symbol] :attack or :save
      # @param save_ability [Symbol, nil] The ability used for the save (if type is :save).
      # @param half_damage_on_save [Boolean] Whether half damage is dealt on a successful save.
      # @param fixed_dc [Integer, nil] A fixed DC for the save (optional).
      # @param dc_stat [Symbol] The stat used to calculate DC if not fixed (default: same as relevant_stat).
      # @param range [Integer] The range of the attack in feet (default: 5).
      def initialize(name:, damage_dice:, relevant_stat: :strength, dice_roller: DiceRoller.new, **options)
        @name = name
        @damage_dice = damage_dice
        @relevant_stat = relevant_stat
        @dice_roller = dice_roller
        @type = options[:type] || :attack
        @save_ability = options[:save_ability]
        @half_damage_on_save = options[:half_damage_on_save] || false
        @fixed_dc = options[:fixed_dc]
        @dc_stat = options[:dc_stat] || relevant_stat
        @range = options[:range] || 5
      end
    end
  end
end
