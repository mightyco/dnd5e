# frozen_string_literal: true

require_relative 'metric'

module Dnd5e
  module Metrics
    # Calculates the average number of rounds a combat scenario lasted.
    class AverageRoundsMetric < Metric
      def calculate(combat_results)
        total_rounds = combat_results.sum(&:rounds)
        total_battles = combat_results.size
        return 0.0 if total_battles.zero?

        (total_rounds.to_f / total_battles).round(1)
      end
    end
  end
end
