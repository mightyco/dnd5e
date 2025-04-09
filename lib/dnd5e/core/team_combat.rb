require_relative "dice"
require_relative "combat"
require_relative "printing_combat_result_handler"
require 'logger'

module Dnd5e
  module Core
    # Manages a combat encounter between two teams.
    class TeamCombat < Combat
      attr_reader :teams, :result_handler

      # Initializes a new TeamCombat instance.
      #
      # @param teams [Array<Team>] The teams participating in the combat.
      # @param result_handler [CombatResultHandler] The handler for combat results.
      # @param logger [Logger] The logger to use for logging.
      # @param dice_roller [DiceRoller] The dice roller to use for rolling dice.
      # @raise [ArgumentError] if the number of teams is not exactly two.
      def initialize(teams:, result_handler: PrintingCombatResultHandler.new, logger: Logger.new($stdout), dice_roller: DiceRoller.new)
        raise ArgumentError, "TeamCombat requires exactly two teams" unless teams.size == 2

        @teams = teams
        @result_handler = result_handler
        super(combatants: teams.first.members + teams.last.members, logger: logger, dice_roller: dice_roller)
      end

      # Runs the combat and handles the results.
      #
      # @return [void]
      def run_combat
        super()
        initiative_winner = @turn_manager.turn_order.first.team
        result_handler.handle_result(self, winner, initiative_winner)
      end

      # Takes a turn for a given attacker, selecting a defender from the opposing team.
      #
      # @param attacker [Combatant] The combatant taking the turn.
      # @return [Combatant, nil] The defender if one is selected, nil otherwise.
      def take_turn(attacker)
        defender = find_valid_defender(attacker)
        return if defender.nil?

        attack(attacker, defender)
      end

      # Checks if the combat is over.
      #
      # @return [Boolean] true if the combat is over, false otherwise.
      def is_over?
        @teams.any? { |team| team.all_members_defeated? }
      end

      # Determines the winning team.
      #
      # @return [Team] The winning team.
      def winner
        @teams.find { |team| !team.all_members_defeated? }
      end

      # Logs the end of a round.
      #
      # @return [void]
      def end_round
        result_handler.logger.info "End of round" if result_handler.respond_to?(:logger)
      end

      private

      # Finds a valid defender for the given attacker.
      #
      # @param attacker [Combatant] The attacking combatant.
      # @return [Combatant, nil] A valid defender if one exists, nil otherwise.
      def find_valid_defender(attacker)
        potential_defenders = @teams.reject { |team| team == attacker.team }.flat_map(&:alive_members)
        potential_defenders.sample
      end
    end
  end
end
