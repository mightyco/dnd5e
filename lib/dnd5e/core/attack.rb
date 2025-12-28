# frozen_string_literal: true

require_relative 'dice'
require_relative 'dice_roller'

module Dnd5e
  module Core
    # Represents an attack action available to a combatant.
    class Attack
      attr_reader :name, :damage_dice, :relevant_stat, :dice_roller, :type, :save_ability, :half_damage_on_save,
                  :fixed_dc, :dc_stat, :range, :scaling, :resource_cost, :area_radius

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
      # @param scaling [Boolean] Whether the damage dice scale with level (default: false).
      # @param resource_cost [Symbol, nil] The resource consumed by this attack (e.g., :spell_slot_3).
      # @param area_radius [Integer, nil] The radius of the AOE in feet (optional).
      def initialize(name:, damage_dice:, relevant_stat: :strength, dice_roller: DiceRoller.new, **options)
        @name = name
        @damage_dice = damage_dice
        @relevant_stat = relevant_stat
        @dice_roller = dice_roller
        assign_options(options)
      end

      def assign_options(options)
        @type = options[:type] || :attack
        @save_ability = options[:save_ability]
        @half_damage_on_save = options[:half_damage_on_save] || false
        @fixed_dc = options[:fixed_dc]
        @dc_stat = options[:dc_stat] || @relevant_stat
        @range = options[:range] || 5
        @scaling = options[:scaling] || false
        @resource_cost = options[:resource_cost]
        @area_radius = options[:area_radius]
      end

      # Returns the damage dice for a given level, applying scaling if enabled.
      #
      # @param level [Integer] The level to calculate damage for.
      # @return [Dice] The (potentially scaled) damage dice.
      def damage_dice_for(level)
        return @damage_dice unless @scaling

        multiplier = calculate_scaling_multiplier(level)
        Dice.new(@damage_dice.count * multiplier, @damage_dice.sides, modifier: @damage_dice.modifier)
      end

      private

      def calculate_scaling_multiplier(level)
        case level
        when 5..10 then 2
        when 11..16 then 3
        when 17..20 then 4
        else 1
        end
      end
    end
  end
end
