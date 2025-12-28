# frozen_string_literal: true

require_relative '../../test_helper'
require_relative '../../../lib/dnd5e/metrics/metric'

module Dnd5e
  module Metrics
    class TestMetric < Minitest::Test
      def test_calculate_raises_not_implemented
        metric = Metric.new
        assert_raises(NotImplementedError) do
          metric.calculate([])
        end
      end
    end
  end
end
