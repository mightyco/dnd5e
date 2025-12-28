# frozen_string_literal: true

require_relative 'result'
require_relative 'combat_result_handler'

require 'logger'

module Dnd5e
  module Simulation
    # Handles combat results without printing to stdout, storing them for analysis.
    class SilentCombatResultHandler < CombatResultHandler
      attr_reader :results, :logger

      def initialize(logger: Logger.new(nil))
        super()
        @results = []
        @logger = logger
      end

      def update(event, data)
        case event
        when :combat_start
          handle_combat_start(data)
        when :combat_end
          handle_combat_end(data)
        end
      end

      def handle_result(_combat, winner, initiative_winner)
        result = Result.new(winner: winner, initiative_winner: initiative_winner)
        @results << result
      end

      private

      def handle_combat_start(data)
        return unless data[:combat].respond_to?(:teams)

        @teams = data[:combat].teams
        @combatant_team_map = {}
        @teams.each do |team|
          team.members.each { |m| @combatant_team_map[m.name] = team }
        end
      end

      def handle_combat_end(data)
        initiative_winner = data[:initiative_winner]
        winner = data[:winner]

        if @combatant_team_map
          if initiative_winner.respond_to?(:name) && @combatant_team_map[initiative_winner.name]
            initiative_winner = @combatant_team_map[initiative_winner.name]
          end
          winner = @combatant_team_map[winner.name] if winner.respond_to?(:name) && @combatant_team_map[winner.name]
        end

        handle_result(nil, winner, initiative_winner)
      end
    end
  end
end
