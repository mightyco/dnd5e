require_relative "dice"
require_relative "combat"
require_relative "printing_combat_result_handler"
require 'logger'

module Dnd5e
  module Core
    class TeamCombat < Combat
      attr_reader :teams, :result_handler

      def initialize(teams:, result_handler: PrintingCombatResultHandler.new, logger: Logger.new($stdout), dice_roller: DiceRoller.new)
        raise ArgumentError, "TeamCombat requires exactly two teams" unless teams.size == 2
        @teams = teams
        @result_handler = result_handler
        super(combatants: teams.first.members + teams.last.members, logger: logger, dice_roller: dice_roller)
      end

      def run_combat
        super()
        initiative_winner = @turn_manager.turn_order.first.team
        result_handler.handle_result(self, winner, initiative_winner)
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
