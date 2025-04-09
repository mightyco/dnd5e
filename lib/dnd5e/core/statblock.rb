module Dnd5e
  module Core
    # Represents a character's stat block in the D&D 5e system.
    class Statblock
      attr_reader :name, :hit_die, :level
      attr_accessor :strength, :dexterity, :constitution, :intelligence, :wisdom, :charisma, :armor_class, :hit_points

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
      def initialize(name:, strength: 10, dexterity: 10, constitution: 10, intelligence: 10, wisdom: 10, charisma: 10, hit_die: "d8", level: 1)
        @name = name
        @strength = strength
        @dexterity = dexterity
        @constitution = constitution
        @intelligence = intelligence
        @wisdom = wisdom
        @charisma = charisma
        @hit_die = hit_die
        @level = level
        @armor_class = 10 + ability_modifier(:dexterity) # Default AC calculation
        @hit_points = calculate_hit_points
      end

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

      # Reduces the character's hit points by the given damage.
      #
      # @param damage [Integer] The amount of damage to take.
      # @raise [ArgumentError] if the damage is negative.
      def take_damage(damage)
        raise ArgumentError, "Damage must be non-negative" if damage < 0
        @hit_points = [0, @hit_points - damage].max
      end

      # Heals the character by the given amount.
      #
      # @param amount [Integer] The amount to heal.
      # @raise [ArgumentError] if the healing amount is negative.
      def heal(amount)
        raise ArgumentError, "Healing amount must be non-negative" if amount < 0
        @hit_points = [calculate_hit_points, @hit_points + amount].min
      end

      # Checks if the character is alive.
      #
      # @return [Boolean] True if the character is alive, false otherwise.
      def is_alive?
        @hit_points > 0
      end

      # Calculates the character's hit points based on their level and constitution.
      #
      # @return [Integer] The character's hit points.
      def calculate_hit_points
        hit_die_sides = @hit_die.sub("d", "").to_i
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
        case @level
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
          raise "Invalid level"
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
