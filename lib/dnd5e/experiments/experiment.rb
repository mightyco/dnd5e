module Dnd5e
  module Experiments
    class Experiment
      attr_reader :name, :control_group_block, :test_group_block, :variables, :simulation_count

      def initialize(name:)
        @name = name
        @variables = {}
        @simulation_count = 100
      end

      # Define how to build the control group (Team A)
      # @yield [Hash] params The current values of independent variables
      # @return [Team]
      def control_group(&block)
        @control_group_block = block
        self
      end

      # Define how to build the test group (Team B)
      # @yield [Hash] params The current values of independent variables
      # @return [Team]
      def test_group(&block)
        @test_group_block = block
        self
      end

      # Add an independent variable to vary
      # @param name [Symbol] Name of variable (e.g. :level)
      # @param values [Array, Range] Values to iterate over
      def independent_variable(name, values:)
        @variables[name] = values.to_a
        self
      end

      def simulations_per_step(count)
        @simulation_count = count
        self
      end

      def run
        require_relative "runner"
        Runner.new(self).run
      end
    end
  end
end
