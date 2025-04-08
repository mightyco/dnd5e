require_relative "metric"

module Dnd5e
  module Metrics
    class AverageRoundsMetric < Metric
      def calculate(combat_results)
        total_rounds = combat_results.sum { |result| result.rounds }
        total_battles = combat_results.size
        return 0.0 if total_battles == 0

        (total_rounds.to_f / total_battles).round(1)
      end
    end
  end
end
