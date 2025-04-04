module Dnd5e
  module Core
    class Attack
      attr_reader :name, :damage_dice, :attack_bonus, :damage_bonus, :range, :count
      attr_reader :relevant_stat

      def initialize(name:, damage_dice:, extra_attack_bonus: 0, extra_damage_bonus: 0, range: :melee, count: 1, relevant_stat: :strength)
        @name = name
        @damage_dice = damage_dice
        @attack_bonus = extra_attack_bonus
        @damage_bonus = extra_damage_bonus
        @range = range
        @count = count
        @relevant_stat = relevant_stat
      end

      def calculate_attack_roll(statblock, roll: nil)
        # Roll the attack die and add the attack bonus
        attack_roll = roll || Dice.new(1, 20).roll.first
        attack_roll + calculate_attack_bonus(statblock)
      end

      def calculate_damage(statblock)
        # Roll the damage dice and add the damage bonus
        damage_roll = @damage_dice.roll.sum
        damage_roll + calculate_damage_bonus(statblock)
      end

      def calculate_attack_bonus(statblock)
        # Calculate the attack bonus based on the statblock's stats
        (@attack_bonus || 0) + statblock.ability_modifier(@relevant_stat) + statblock.proficiency_bonus
      end

      def calculate_damage_bonus(statblock)
        # Calculate the damage bonus based on the statblock's stats
        (@damage_bonus || 0) + statblock.ability_modifier(@relevant_stat)
      end
    end
  end
end
