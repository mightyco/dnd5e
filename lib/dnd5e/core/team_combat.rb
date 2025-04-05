module Dnd5e
  require_relative "dice"
  require_relative "combat"

  module Core
    class TeamCombat < Combat
      attr_reader :teams

      def initialize(teams:)
        raise ArgumentError, "TeamCombat requires exactly two teams" unless teams.size == 2
        @teams = teams
        super(combatant1: teams.first.members.first, combatant2: teams.last.members.first)
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

      def take_turn(attacker)
        potential_defenders = @teams.reject { |team| team == attacker.team }.flat_map(&:alive_members)
        return if potential_defenders.empty?
        defender = potential_defenders.first
        attack(attacker, defender)
      end

      def is_over?
        @teams.count { |team| team.any_members_alive? } <= 1
      end

      def winner
        @teams.find { |team| team.any_members_alive? }
      end

      def end_round
        puts "End of round"
      end
    end
  end
end
