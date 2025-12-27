# frozen_string_literal: true

require_relative 'dice'
require_relative 'combat'
require_relative 'printing_combat_result_handler'
require 'logger'

module Dnd5e
  module Core
    # Manages a combat encounter between two teams.
    class TeamCombat < Combat
      attr_reader :teams

      # Initializes a new TeamCombat instance.
      #
      # @param teams [Array<Team>] The teams participating in the combat.
      # @param dice_roller [DiceRoller] The dice roller to use for rolling dice.
      # @raise [ArgumentError] if the number of teams is not exactly two.
      def initialize(teams:, dice_roller: DiceRoller.new)
        raise ArgumentError, 'TeamCombat requires exactly two teams' unless teams.size == 2

        @teams = teams
        # result_handler and logger are deprecated/ignored here, handled via observers
        super(combatants: teams.first.members + teams.last.members, dice_roller: dice_roller)
      end

      # Runs the combat and handles the results.
      #
      # @return [void]

      # Takes a turn for a given attacker, selecting a defender from the opposing team.
      #
      # @param attacker [Combatant] The combatant taking the turn.
      # @return [Combatant, nil] The defender if one is selected, nil otherwise.
      def take_turn(attacker)
        notify_observers(:turn_start, combatant: attacker)
        defender = find_valid_defender(attacker)
        return if defender.nil?

        attack(attacker, defender)
      end

      # Checks if the combat is over.
      #
      # @return [Boolean] true if the combat is over, false otherwise.
      def over?
        @teams.any?(&:all_members_defeated?)
      end

      alias is_over? over?

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
        # Deprecated: logging handled by observers
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
