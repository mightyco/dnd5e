module Dnd5e
  module Core
    class Statblock
      attr_reader :name, :strength, :dexterity, :constitution, :intelligence, :wisdom, :charisma, :hit_points, :armor_class

      def initialize(name:, strength:, dexterity:, constitution:, intelligence:, wisdom:, charisma:, hit_points:, armor_class:)
        @name = name
        @strength = strength
        @dexterity = dexterity
        @constitution = constitution
        @intelligence = intelligence
        @wisdom = wisdom
        @charisma = charisma
        @hit_points = hit_points
        @armor_class = armor_class
      end

      def ability_modifier(ability)
        score = instance_variable_get("@#{ability}")
        ((score - 10) / 2).floor
      end

      def is_alive?
        @hit_points > 0
      end

      def take_damage(damage)
        @hit_points -= damage
      end
    end
  end
end
