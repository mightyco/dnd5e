# frozen_string_literal: true

module Dnd5e
  module Simulation
    # Represents the result of a single combat simulation.
    class Result
      attr_reader :winner, :initiative_winner

      def initialize(winner:, initiative_winner:)
        @winner = winner
        @initiative_winner = initiative_winner
      end
    end
  end
end
