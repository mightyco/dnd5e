# frozen_string_literal: true

module Dnd5e
  module Metrics
    class Metric
      def calculate(combat_results)
        raise NotImplementedError, 'Subclasses must implement calculate'
      end
    end
  end
end
