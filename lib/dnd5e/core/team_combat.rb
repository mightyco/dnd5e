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

      # Finds a valid defender for the given attacker.
      #
      # @param attacker [Combatant] The attacking combatant.
      # @return [Combatant, nil] A valid defender if one exists, nil otherwise.
      def find_valid_defender(attacker)
        attacker.team ||= @teams.find { |t| t.members.include?(attacker) }
        enemy_teams = @teams.reject { |team| team == attacker.team }
        potential_defenders = enemy_teams.flat_map(&:alive_members)

        # Priority Targeting: Geek the Mage (Target with lowest current HP)
        potential_defenders.min_by { |c| c.statblock.hit_points }
      end

      def take_turn(attacker)
        # We need to preserve team context for the strategy to find targets
        attacker.team ||= @teams.find { |t| t.members.include?(attacker) }
        super
      end

      def over?
        @teams.any?(&:all_members_defeated?)
      end

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

      # Deprecated: legacy turn logic moved to strategies
      def execute_legacy_turn(attacker)
        defender = find_valid_defender(attacker)
        return false if defender.nil?

        attack(attacker, defender)
      end
    end
  end
end
