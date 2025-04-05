module Dnd5e
  module Core
    class Statblock
      attr_reader :name, :hit_die, :level
      attr_accessor :strength, :dexterity, :constitution, :intelligence, :wisdom, :charisma, :armor_class, :hit_points

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

      def ability_modifier(ability)
        score = instance_variable_get("@#{ability}")
        raise ArgumentError, "Invalid ability: #{ability}" unless score

        (score - 10) / 2
      end

      def take_damage(damage)
        raise ArgumentError, "Damage must be non-negative" if damage < 0
        @hit_points = [0, @hit_points - damage].max
      end

      def heal(amount)
        raise ArgumentError, "Healing amount must be non-negative" if amount < 0
        @hit_points = [calculate_hit_points, @hit_points + amount].min
      end

      def is_alive?
        @hit_points > 0
      end

      def calculate_hit_points
        hit_die_sides = @hit_die.sub("d", "").to_i
        base_hp = hit_die_sides + ability_modifier(:constitution)
        @level > 1 ? base_hp + (((hit_die_sides + 1) / 2.0).ceil + ability_modifier(:constitution)) * (@level - 1) : base_hp
      end

      def level_up
        @level += 1
        @hit_points = calculate_hit_points
      end

      def proficiency_bonus
        # Proficiency bonus increases with level
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

      # Deep copy method
      def deep_copy
        Marshal.load(Marshal.dump(self))
      end
    end
  end
end
