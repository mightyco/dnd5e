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
          take_turn(current_combatant) if current_combatant.statblock.is_alive?
          switch_turns if not is_over?
        end
        puts "The winner is #{winner.name}"
        return
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
        return if not attacker.statblock.is_alive?

        defender = attacker == @combatant1 ? @combatant2 : @combatant1
        attack(attacker, defender)
      end

      def attack(attacker, defender)
        return if not (attacker.statblock.is_alive? || defender.statblock.is_alive?)
        attack = attacker.attacks.first
        return if attack.nil?

        attack_roll = calculate_attack_roll(attacker)
        if is_hit?(attack_roll, defender)
          damage = calculate_damage(attacker)
          apply_damage(defender, damage)
          puts "#{attacker.name} hits #{defender.name} for #{damage} damage!"
          if not defender.statblock.is_alive?
            puts "#{defender.name} is defeated!"
          end
        else
          puts "#{attacker.name} misses #{defender.name}!"
        end
      end

      def calculate_attack_roll(attacker)
        attack = attacker.attacks.first
        return if attack.nil?

        attack_roll = attack.calculate_attack_roll(attacker.statblock)
        attack_roll
      end

      def calculate_damage(attacker)
        attack = attacker.attacks.first
        return if attack.nil?

        damage = attack.calculate_damage(attacker.statblock)
        damage
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
        return @combatant1 if @combatant2.statblock.hit_points <= 0
        return @combatant2 if @combatant1.statblock.hit_points <= 0
        nil
      end

      def current_combatant
        @turn_order.first
      end

      def switch_turns
        @turn_order.rotate!
      end
    end
  end
end
