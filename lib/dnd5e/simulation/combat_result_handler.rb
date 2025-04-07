module Dnd5e
  module Simulation
    class CombatResultHandler
      attr_reader :results

      def initialize
        @results = []
      end

      def handle_result(combat, winner, initiative_winner)
        raise NotImplementedError, "Subclasses must implement handle_result"
      end
    end
  end
end
