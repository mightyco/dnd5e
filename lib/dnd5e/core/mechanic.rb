# frozen_string_literal: true

module Dnd5e
  module Core
    # Represents a core mechanic rule (e.g. "Grappling").
    class Mechanic
      attr_reader :name, :description

      def initialize(name:, description:)
        @name = name
        @description = description
      end
    end
  end
end
