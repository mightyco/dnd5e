# /home/chuck_mcintyre/src/dnd5e/lib/dnd5e/core/statblock.rb
module Dnd5e
  module Core
    class Statblock
      attr_reader :name, :hit_points, :hit_die
      attr_accessor :strength, :dexterity, :constitution, :intelligence, :wisdom, :charisma, :armor_class

      def initialize(name:, strength: 10, dexterity: 10, constitution: 10, intelligence: 10, wisdom: 10, charisma: 10, hit_die: "d8")
        @name = name
        @strength = strength
        @dexterity = dexterity
        @constitution = constitution
        @intelligence = intelligence
        @wisdom = wisdom
        @charisma = charisma        
        @hit_die = hit_die        
        @armor_class = 10 + ability_modifier(:dexterity) # Default AC calculation
        @hit_points = calculate_hit_points(1)
      end

      def ability_modifier(ability)
        score = instance_variable_get("@#{ability}")
        raise ArgumentError, "Invalid ability: #{ability}" unless score

        (score - 10) / 2
      end

      def take_damage(damage)
        raise ArgumentError, "Damage must be non-negative" if damage < 0

        @hit_points -= damage
      end

      def heal(amount)
        raise ArgumentError, "Healing amount must be non-negative" if amount < 0

        @hit_points += amount
      end

      def is_alive?
        @hit_points > 0
      end

      def calculate_hit_points(level)
        # Calculate initial hit points based on hit die and constitution modifier
        hit_die_sides = @hit_die.sub("d", "").to_i
        hit_points = hit_die_sides + ability_modifier(:constitution)
        if level > 1
          hit_points += (((hit_die_sides + 1) / 2.0).ceil + ability_modifier(:constitution)) * (level - 1)
        end
        hit_points
      end
    end
  end
end
