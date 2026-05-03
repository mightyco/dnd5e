# frozen_string_literal: true

module Dnd5e
  module Simulation
    # Builder for creating Simulation::Scenario objects.
    class ScenarioBuilder
      def initialize(num_simulations: 1000, max_rounds: 100, distance: 30)
        @num_simulations = num_simulations
        @max_rounds = max_rounds
        @distance = distance
        @teams = []
      end

      def with_team(team)
        @teams << team
        self
      end

      def build
        Scenario.new(
          teams: @teams,
          num_simulations: @num_simulations,
          max_rounds: @max_rounds,
          distance: @distance
        )
      end
    end
  end
end
