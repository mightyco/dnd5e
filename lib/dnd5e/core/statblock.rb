# frozen_string_literal: true

module Dnd5e
  module Core
    # Represents a character's stat block in the D&D 5e system.
    class Statblock
      attr_reader :name, :hit_die, :level
      attr_accessor :strength, :dexterity, :constitution, :intelligence, :wisdom, :charisma, :hit_points,
                    :saving_throw_proficiencies, :equipped_armor, :equipped_shield

      # Initializes a new Statblock.
      #
      # @param name [String] The name of the character.
      # @param strength [Integer] The character's strength score.
      # @param dexterity [Integer] The character's dexterity score.
      # @param constitution [Integer] The character's constitution score.
      # @param intelligence [Integer] The character's intelligence score.
      # @param wisdom [Integer] The character's wisdom score.
      # @param charisma [Integer] The character's charisma score.
      # @param hit_die [String] The character's hit die (e.g., "d8").
      # @param level [Integer] The character's level.
      # @param saving_throw_proficiencies [Array<Symbol>] List of abilities the character has save proficiency in.
      # @param equipped_armor [Armor, nil] The armor the character is wearing.
      # @param equipped_shield [Armor, nil] The shield the character is holding.
      def initialize(name:, strength: 10, dexterity: 10, constitution: 10, intelligence: 10, wisdom: 10, charisma: 10,
                     hit_die: 'd8', level: 1, saving_throw_proficiencies: [], equipped_armor: nil, equipped_shield: nil)
        @name = name
        @strength = strength
        @dexterity = dexterity
        @constitution = constitution
        @intelligence = intelligence
        @wisdom = wisdom
        @charisma = charisma
        @hit_die = hit_die
        @level = level
        @saving_throw_proficiencies = saving_throw_proficiencies
        @equipped_armor = equipped_armor
        @equipped_shield = equipped_shield
        @hit_points = calculate_hit_points
      end

      # Calculates the Armor Class (AC).
      #
      # @return [Integer] The calculated AC.
      def armor_class
        return @armor_class if defined?(@armor_class) && @armor_class # Manual override priority

        base = if @equipped_armor
                 @equipped_armor.calculate_ac(ability_modifier(:dexterity))
               else
                 10 + ability_modifier(:dexterity)
               end

        base += @equipped_shield.base_ac if @equipped_shield
        base
      end

      # Deprecated accessor for backward compatibility if needed, but we want dynamic calc.
      # If we allow setting AC manually (for monsters), we need to store an override.
      attr_writer :armor_class

      # Calculates the ability modifier for a given ability.
      #
      # @param ability [Symbol] The ability to calculate the modifier for (e.g., :strength).
      # @return [Integer] The ability modifier.
      # @raise [ArgumentError] if the ability is invalid.
      def ability_modifier(ability)
        score = instance_variable_get("@#{ability}")
        raise ArgumentError, "Invalid ability: #{ability}" unless score

        (score - 10) / 2
      end

      # Checks if the character is proficient in a saving throw.
      #
      # @param ability [Symbol] The ability to check.
      # @return [Boolean] True if proficient, false otherwise.
      def proficient_in_save?(ability)
        @saving_throw_proficiencies.include?(ability)
      end

      # Calculates the saving throw modifier for a given ability.
      #
      # @param ability [Symbol] The ability to calculate the modifier for.
      # @return [Integer] The saving throw modifier.
      def save_modifier(ability)
        mod = ability_modifier(ability)
        mod += proficiency_bonus if proficient_in_save?(ability)
        mod
      end

      # Reduces the character's hit points by the given damage.
      #
      # @param damage [Integer] The amount of damage to take.
      # @raise [ArgumentError] if the damage is negative.
      def take_damage(damage)
        raise ArgumentError, 'Damage must be non-negative' if damage.negative?

        @hit_points = [0, @hit_points - damage].max
      end

      # Heals the character by the given amount.
      #
      # @param amount [Integer] The amount to heal.
      # @raise [ArgumentError] if the healing amount is negative.
      def heal(amount)
        raise ArgumentError, 'Healing amount must be non-negative' if amount.negative?

        @hit_points = [calculate_hit_points, @hit_points + amount].min
      end

      # Checks if the character is alive.
      #
      # @return [Boolean] True if the character is alive, false otherwise.
      def is_alive?
        @hit_points.positive?
      end

      # Calculates the character's hit points based on their level and constitution.
      #
      # @return [Integer] The character's hit points.
      def calculate_hit_points
        hit_die_sides = @hit_die.sub('d', '').to_i
        base_hp = hit_die_sides + ability_modifier(:constitution)
        return base_hp if @level == 1

        additional_hp_per_level = ((hit_die_sides + 1) / 2.0).ceil + ability_modifier(:constitution)
        base_hp + additional_hp_per_level * (@level - 1)
      end

      # Levels up the character.
      def level_up
        @level += 1
        @hit_points = calculate_hit_points
      end

      # Calculates the character's proficiency bonus based on their level.
      #
      # @return [Integer] The character's proficiency bonus.
      # @raise [RuntimeError] if the level is invalid.
      def proficiency_bonus
        self.class.calculate_proficiency_bonus(@level)
      end

      # Calculates proficiency bonus for a given level.
      #
      # @param level [Integer] Character level (1-20).
      # @return [Integer] Proficiency bonus.
      def self.calculate_proficiency_bonus(level)
        case level
        when 1..4
          2
        when 5..8
          3
        when 9..12
          4
        when 13..16
          5
        when 17..20
          6
        else
          raise "Invalid level: #{level}"
        end
      end

      # Creates a deep copy of the Statblock.
      #
      # @return [Statblock] A deep copy of the Statblock.
      def deep_copy
        Marshal.load(Marshal.dump(self))
      end
    end
  end
end
