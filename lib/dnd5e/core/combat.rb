module Dnd5e
  require_relative "dice"
  module Core
    class Team
      attr_reader :name, :members

      def initialize(name:, members: [])
        @name = name
        @members = members
      end

      def add_member(member)
        @members << member
        member.team = self
      end

      def all_members_defeated?
        @members.all? { |member| !member.statblock.is_alive? }
      end

      def any_members_alive?
        @members.any? { |member| member.statblock.is_alive? }
      end

      def alive_members
        @members.select { |member| member.statblock.is_alive? }
      end
    end

    # Enhanced Combat class
    class Combat
      attr_reader :teams, :turn_order

      def initialize(teams:)
        @teams = teams
        @turn_order = []
      end

      def start
        roll_initiative
        sort_by_initiative
        until is_over?
          @turn_order.each do |combatant|
            take_turn(combatant) if combatant.statblock.is_alive?
          end
          end_round
        end
        puts "The winner is #{winner.name}"
      end

      def roll_initiative
        @teams.each do |team|
          team.members.each do |combatant|
            initiative_roll = Dice.new(1, 20, modifier: combatant.statblock.ability_modifier(:dexterity)).roll.first
            combatant.instance_variable_set(:@initiative, initiative_roll)
            @turn_order << combatant
          end
        end
      end

      def sort_by_initiative
        @turn_order = @turn_order.sort_by { |combatant| -combatant.instance_variable_get(:@initiative) }
      end

      def take_turn(attacker)
        # Get all members of other teams that are alive
        potential_defenders = @teams.reject { |team| team == attacker.team }.flat_map(&:alive_members)

        # If there are no potential defenders, exit
        return if potential_defenders.empty?

        # Always select the first defender
        defender = potential_defenders.first

        # Attack the defender
        attack(attacker, defender)
      end

      def attack(attacker, defender)
        # Use the first attack in the attacker's attack list
        attack = attacker.attacks.first
        return if attack.nil?

        attack_roll = attack.calculate_attack_roll(attacker.statblock)
        if is_hit?(attack_roll, defender)
          damage = attack.calculate_damage(attacker.statblock)
          apply_damage(defender, damage)
          puts "#{attacker.name} hits #{defender.name} for #{damage} damage!"
        else
          puts "#{attacker.name} misses #{defender.name}!"
        end
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
        # Use the first attack in the attacker's attack list
        attack = attacker.attacks.first
        return if attack.nil?

        attack_roll = attack.calculate_attack_roll(attacker.statblock)
        attack_roll
      end

      def calculate_damage(attacker)
        # Use the first attack in the attacker's attack list
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
        # Check if only one team has members alive
        @teams.count { |team| team.any_members_alive? } <= 1
      end

      def winner
        # Return the winning team
        @teams.find { |team| team.any_members_alive? }
      end

      def end_round
        puts "End of round"
      end
    end
  end
end
