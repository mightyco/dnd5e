require_relative "combat_result_handler"

module Dnd5e
  module Core
    class PrintingCombatResultHandler
      include CombatResultHandler

      def handle_result(combat, winner, initiative_winner)
        puts "The winner is #{winner.name}"
      end
    end
  end
end
