require_relative "dice"
require_relative "combat"
require_relative "printing_combat_result_handler"
require 'logger'

module Dnd5e
  module Core
    class TeamCombat < Combat
      attr_reader :teams, :result_handler

      def initialize(teams:, result_handler: PrintingCombatResultHandler.new)
        raise ArgumentError, "TeamCombat requires exactly two teams" unless teams.size == 2
        @teams = teams
        @result_handler = result_handler
        super(combatant1: teams.first.members.first, combatant2: teams.last.members.first)
      end

      def start
        initiative_winner = roll_initiative
        sort_by_initiative
        until is_over?
          @turn_order.each do |combatant|
            take_turn(combatant) if combatant.statblock.is_alive?
          end
          end_round
        end
        result_handler.handle_result(self, winner, initiative_winner)
      end

      def roll_initiative
        @teams.each do |team|
          team.members.each do |combatant|
            initiative_roll = Dice.new(1, 20, modifier: combatant.statblock.ability_modifier(:dexterity)).roll.first
            combatant.instance_variable_set(:@initiative, initiative_roll)
            @turn_order << combatant
          end
        end
        @teams.max_by { |team| team.members.max_by { |member| member.instance_variable_get(:@initiative) }.instance_variable_get(:@initiative) }
      end

      def take_turn(attacker)
        potential_defenders = @teams.reject { |team| team == attacker.team }.flat_map(&:alive_members)
        return if potential_defenders.empty?
        defender = potential_defenders.sample
        attack(attacker, defender)
      end

      def is_over?
        @teams.any? { |team| team.all_members_defeated? }
      end

      def winner
        @teams.find { |team| !team.all_members_defeated? }
      end

      def end_round
        result_handler.logger.info "End of round" if result_handler.respond_to?(:logger)
      end
    end
  end
end
