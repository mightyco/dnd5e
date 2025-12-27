# frozen_string_literal: true

require_relative 'dice'
require_relative 'dice_roller'

module Dnd5e
  module Core
    # Represents an attack or action in the D&D 5e system.
    class Attack
      attr_reader :name, :damage_dice, :relevant_stat, :dice_roller, :type, :save_ability, :dc_stat, :fixed_dc,
                  :half_damage_on_save

      # Initializes a new Attack.
      #
      # @param name [String] The name of the attack.
      # @param damage_dice [Dice] The dice used for damage.
      # @param relevant_stat [Symbol] The relevant stat for the attack (e.g., :strength) or for DC calculation.
      # @param dice_roller [DiceRoller] The dice roller to use.
      # @param type [Symbol] The type of action (:attack or :save).
      # @param save_ability [Symbol] The ability used for the saving throw (if type is :save).
      # @param dc_stat [Symbol] The stat used to calculate DC (if type is :save). Defaults to relevant_stat.
      # @param fixed_dc [Integer, nil] A fixed DC value, overriding dynamic calculation.
      # @param half_damage_on_save [Boolean] Whether the target takes half damage on a successful save.
      def initialize(name:, damage_dice:, relevant_stat: :strength, dice_roller: DiceRoller.new, type: :attack,
                     save_ability: nil, dc_stat: nil, fixed_dc: nil, half_damage_on_save: false)
        @name = name
        @damage_dice = damage_dice
        @relevant_stat = relevant_stat
        @dice_roller = dice_roller
        @type = type
        @save_ability = save_ability
        @dc_stat = dc_stat || relevant_stat
        @fixed_dc = fixed_dc
        @half_damage_on_save = half_damage_on_save
      end
    end
  end
end
