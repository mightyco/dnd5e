# frozen_string_literal: true

module Dnd5e
  # Module for handling combat results.
  # This module defines the interface for handling the outcome of a combat.
  module CombatResultHandler
    # Handles the result of a combat.
    # @param combat [Object] The combat object.
    # @param winner [Object] The winner of the combat.
    # @param initiative_winner [Object] The winner of the initiative roll.
    # @raise [NotImplementedError] if the method is not implemented in a subclass.
    def handle_result(combat, winner, initiative_winner)
      raise NotImplementedError, 'Subclasses must implement handle_result'
    end
  end
end
