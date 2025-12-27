# frozen_string_literal: true

require_relative 'metric'

module Dnd5e
  module Metrics
    class WinPercentageMetric < Metric
      def initialize(team_name:)
        @team_name = team_name
      end

      def calculate(combat_results)
        total_battles = combat_results.size
        return 0.0 if total_battles.zero?

        wins = combat_results.count { |result| result.winner.name == @team_name }
        (wins.to_f / total_battles * 100).round(1)
      end
    end
  end
end
