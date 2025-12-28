# frozen_string_literal: true

module Dnd5e
  module Core
    # Represents a status condition (e.g., Prone, Grappled).
    class Condition
      attr_reader :name, :description, :mechanics

      # @param name [String] The name of the condition.
      # @param description [String] Text description of the condition.
      # @param mechanics [Hash] Structured mechanical effects (e.g., { advantage_on_attack: true }).
      def initialize(name:, description: '', mechanics: {})
        @name = name
        @description = description
        @mechanics = mechanics
      end
    end
  end
end
