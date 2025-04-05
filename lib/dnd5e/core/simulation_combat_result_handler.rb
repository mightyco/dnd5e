require_relative "combat_result_handler"
require_relative "../simulation/result"

module Dnd5e
  module Core
    class SimulationCombatResultHandler
      include CombatResultHandler

      def handle_result(combat, winner, initiative_winner)
        Dnd5e::Simulation::Result.new(winner: winner, initiative_winner: initiative_winner)
      end
    end
  end
end
