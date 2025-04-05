module Dnd5e
  module Simulation
    class Result
      attr_reader :winner, :initiative_winner

      def initialize(winner:, initiative_winner:)
        @winner = winner
        @initiative_winner = initiative_winner
      end
    end
  end
end
