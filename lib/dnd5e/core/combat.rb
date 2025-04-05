module Dnd5e
  require_relative "dice"
  module Core
    class Combat
      attr_reader :combatant1, :combatant2, :turn_order

      def initialize(combatant1:, combatant2:)
        @combatant1 = combatant1
        @combatant2 = combatant2
        @turn_order = []
      end

      def start
        roll_initiative
        sort_by_initiative
        until is_over?
          take_turn(current_combatant)
          switch_turns unless is_over?
        end
        puts "The winner is #{winner.name}"
      end

      def roll_initiative
        @combatant1.instance_variable_set(:@initiative, Dice.new(1, 20, modifier: @combatant1.statblock.ability_modifier(:dexterity)).roll.first)
        @combatant2.instance_variable_set(:@initiative, Dice.new(1, 20, modifier: @combatant2.statblock.ability_modifier(:dexterity)).roll.first)
        @turn_order = [@combatant1, @combatant2]
      end

      def sort_by_initiative
        @turn_order.sort_by! do |combatant|
          [-combatant.instance_variable_get(:@initiative), -combatant.statblock.ability_modifier(:dexterity)]
        end
      end

      def take_turn(attacker)
        return unless attacker.statblock.is_alive?

        defender = select_defender(attacker)
        attack(attacker, defender)
      end

      def attack(attacker, defender)
        return unless attacker.statblock.is_alive? && defender.statblock.is_alive?

        attack_instance = attacker.attacks.first
        return if attack_instance.nil?

        attack_roll = calculate_attack_roll(attacker, attack_instance)
        if is_hit?(attack_roll, defender)
          damage = calculate_damage(attacker, attack_instance)
          apply_damage(defender, damage)
          puts "#{attacker.name} hits #{defender.name} for #{damage} damage!"
          puts "#{defender.name} is defeated!" unless defender.statblock.is_alive?
        else
          puts "#{attacker.name} misses #{defender.name}!"
        end
      end

      def calculate_attack_roll(attacker, attack)
        attack.calculate_attack_roll(attacker.statblock)
      end

      def calculate_damage(attacker, attack)
        attack.calculate_damage(attacker.statblock)
      end

      def is_hit?(attack_roll, defender)
        attack_roll >= defender.statblock.armor_class
      end

      def apply_damage(defender, damage)
        defender.statblock.take_damage(damage)
      end

      def is_over?
        !@combatant1.statblock.is_alive? || !@combatant2.statblock.is_alive?
      end

      def winner
        return @combatant1 unless @combatant2.statblock.is_alive?
        return @combatant2 unless @combatant1.statblock.is_alive?

        nil
      end

      def current_combatant
        @turn_order.first
      end

      def switch_turns
        @turn_order.rotate!
      end

      private

      def select_defender(attacker)
        attacker == @combatant1 ? @combatant2 : @combatant1
      end
    end
  end
end
