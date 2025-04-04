module Dnd5e
  require_relative "dice"
  module Core
    class Battle
      attr_reader :combatants, :turn_order

      def initialize(combatants:)
        @combatants = combatants
        @turn_order = []
      end

      def start
        roll_initiative
        sort_by_initiative
        # ... start the battle loop ...
      end

      def roll_initiative
        @combatants.each do |combatant|
          initiative_roll = Dice.new(1, 20, modifier: combatant.statblock.ability_modifier(:dexterity)).roll.first
          combatant.instance_variable_set(:@initiative, initiative_roll)
        end
      end

      def sort_by_initiative
        @turn_order = @combatants.sort_by { |combatant| -combatant.instance_variable_get(:@initiative) }
      end

      def next_turn
        # ... logic to advance to the next turn ...
      end

      def attack(attacker, defender)
        attack_roll = calculate_attack_roll(attacker)
        if is_hit?(attack_roll, defender)
          damage = calculate_damage(attacker)
          apply_damage(defender, damage)
          puts "#{attacker.name} hits #{defender.name} for #{damage} damage!"
        else
          puts "#{attacker.name} misses #{defender.name}!"
        end
      end

      def calculate_attack_roll(attacker)
        attack_dice = Dice.new(1, 20, modifier: attacker.statblock.ability_modifier(:strength) + attacker.statblock.proficiency_bonus)
        attack_dice.roll.first
      end

      def calculate_damage(attacker)
        # Assuming a simple weapon for now (e.g., 1d6)
        damage_dice = Dice.new(1, 6, modifier: attacker.statblock.ability_modifier(:strength))
        damage_dice.roll.first
      end

      def is_hit?(attack_roll, defender)
        attack_roll >= defender.statblock.armor_class
      end

      def apply_damage(defender, damage)
        defender.statblock.take_damage(damage)
      end

      def is_over?
        # ... logic to check if the battle is over ...
      end

      def winner
        # ... logic to determine the winner ...
      end
    end
  end
end
