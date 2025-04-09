module Dnd5e
  module Simulation
    # Class for handling combat results in simulations.
    # This class is responsible for storing and processing the results of combat simulations.
    class CombatResultHandler
      attr_reader :results

      def initialize
        @results = []
      end

      # Handles the result of a combat simulation.
      #
      # @param combat [Object] The combat object.
      # @param winner [Object] The winner of the combat.
      # @param initiative_winner [Object] The winner of the initiative roll.
      # @raise [NotImplementedError] if the method is not implemented in a subclass.
      def handle_result(combat, winner, initiative_winner)
        raise NotImplementedError, "Subclasses must implement handle_result"
      end
    end
  end
end
