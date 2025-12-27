# frozen_string_literal: true

require_relative 'result'
require_relative 'combat_result_handler'

require 'logger'

module Dnd5e
  module Simulation
    class SilentCombatResultHandler < CombatResultHandler
      attr_reader :results, :logger

      def initialize(logger: Logger.new(nil))
        super()
        @results = []
        @logger = logger
      end

      def update(event, data)
        if event == :combat_start
          if data[:combat].respond_to?(:teams)
            @teams = data[:combat].teams
            @combatant_team_map = {}
            @teams.each do |team|
              team.members.each { |m| @combatant_team_map[m.name] = team }
            end
          end
        elsif event == :combat_end
          initiative_winner = data[:initiative_winner]
          if @combatant_team_map && initiative_winner.respond_to?(:name) && @combatant_team_map[initiative_winner.name]
            initiative_winner = @combatant_team_map[initiative_winner.name]
          end
          handle_result(nil, data[:winner], initiative_winner)
        end
      end

      def handle_result(_combat, winner, initiative_winner)
        result = Result.new(winner: winner, initiative_winner: initiative_winner)
        @results << result
      end
    end
  end
end
