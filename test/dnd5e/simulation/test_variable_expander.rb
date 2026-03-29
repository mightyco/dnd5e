# frozen_string_literal: true

require_relative '../../test_helper'
require_relative '../../../lib/dnd5e/simulation/variable_expander'

module Dnd5e
  module Simulation
    class VariableExpanderTest < Minitest::Test
      def setup
        @expander = VariableExpander.new
      end

      def test_expand_no_variables
        preset = { 'name' => 'Static' }
        expanded = @expander.expand(preset)

        assert_equal [preset], expanded
      end

      def test_expand_single_variable
        preset = { 'name' => 'Sweep {{count}}', 'variables' => { 'count' => [1, 2] },
                   'teams' => [{ 'count' => '{{count}}' }] }
        expanded = @expander.expand(preset)

        assert_equal 2, expanded.length
        assert_equal 1, expanded[0]['teams'][0]['count']
        assert_equal 'Sweep 1', expanded[0]['name']
      end

      def test_expand_multiple_variables
        preset = { 'variables' => { 'subclass' => %w[champion battlemaster], 'level' => [1, 5] } }
        expanded = @expander.expand(preset)

        assert_equal 4, expanded.length
        expected_params = [
          { 'subclass' => 'champion', 'level' => 1 },
          { 'subclass' => 'champion', 'level' => 5 },
          { 'subclass' => 'battlemaster', 'level' => 1 },
          { 'subclass' => 'battlemaster', 'level' => 5 }
        ]

        assert_equal(expected_params, expanded.map { |e| e['sweep_parameters'] })
      end
    end
  end
end
