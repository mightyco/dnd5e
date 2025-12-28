# frozen_string_literal: true

module Dnd5e
  module Core
    module Strategies
      # Base class for combat strategies.
      class BaseStrategy
        # Executes the turn for the given combatant.
        #
        # @param combatant [Character, Monster] The combatant taking the turn.
        # @param combat [Combat] The combat instance.
        def execute_turn(combatant, combat)
          raise NotImplementedError, "#{self.class} has not implemented method '#{__method__}'"
        end
      end
    end
  end
end
