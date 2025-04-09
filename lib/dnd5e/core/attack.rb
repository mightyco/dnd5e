require_relative "dice"
require_relative "dice_roller"

module Dnd5e
  module Core
    # Represents an attack in the D&D 5e system.
    class Attack
      attr_reader :name, :damage_dice, :relevant_stat, :dice_roller

      # Initializes a new Attack.
      #
      # @param name [String] The name of the attack.
      # @param damage_dice [Dice] The dice used for damage.
      # @param relevant_stat [Symbol] The relevant stat for the attack (e.g., :strength, :dexterity).
      # @param dice_roller [DiceRoller] The dice roller to use.
      def initialize(name:, damage_dice:, relevant_stat: :strength, dice_roller: DiceRoller.new)
        @name = name
        @damage_dice = damage_dice
        @relevant_stat = relevant_stat
        @dice_roller = dice_roller
      end

      # Performs an attack against a defender.
      #
      # @param attacker [Character] The attacking character.
      # @param defender [Character] The defending character.
      # @return [Boolean] True if the attack hits, false otherwise.
      def attack(attacker, defender)
        attack_roll = @dice_roller.roll_with_dice(Dice.new(1, 20, modifier: attacker.statblock.ability_modifier(@relevant_stat)))
        attack_roll >= defender.statblock.armor_class
      end

      # Calculates the damage of the attack.
      #
      # @param attacker [Character] The attacking character.
      # @return [Integer] The damage dealt.
      def calculate_damage(attacker)
        @dice_roller.roll_with_dice(@damage_dice)
      end
    end
  end
end
