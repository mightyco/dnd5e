# lib/dnd5e/core/combat_result_handler.rb
module Dnd5e
  module Core
    module CombatResultHandler
      def handle_result(combat, winner, initiative_winner)
        raise NotImplementedError, "Subclasses must implement handle_result"
      end
    end
  end
end
