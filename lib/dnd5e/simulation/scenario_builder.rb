# frozen_string_literal: true

module Dnd5e
  module Simulation
    class ScenarioBuilder
      def initialize(num_simulations: 1000)
        @num_simulations = num_simulations
        @teams = []
      end

      def with_team(team)
        @teams << team
        self
      end

      def build
        Scenario.new(teams: @teams, num_simulations: @num_simulations)
      end
    end
  end
end
