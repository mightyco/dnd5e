# frozen_string_literal: true

module Dnd5e
  module Simulation
    class Scenario
      attr_reader :teams, :num_simulations

      def initialize(teams:, num_simulations:)
        raise ArgumentError, 'A scenario must have at least two teams' unless teams.length >= 2
        raise ArgumentError, 'Teams must be of type Core::Team' unless teams.all? { |team| team.is_a?(Core::Team) }

        @teams = teams
        @num_simulations = num_simulations
      end
    end
  end
end
