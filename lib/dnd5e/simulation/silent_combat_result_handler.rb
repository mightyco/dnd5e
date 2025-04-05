module Dnd5e
  module Simulation
    class SilentCombatResultHandler
      def initialize
        @results = []
      end

      def handle_result(combat, winner, initiative_winner)
        result = Result.new(winner: winner, initiative_winner: initiative_winner)
        @results << result
      end

      def results
        @results
      end
    end
  end
end
