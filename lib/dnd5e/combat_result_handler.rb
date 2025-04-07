module Dnd5e
    module CombatResultHandler
      def handle_result(combat, winner, initiative_winner)
        raise NotImplementedError, "Subclasses must implement handle_result"
      end
    end
end
