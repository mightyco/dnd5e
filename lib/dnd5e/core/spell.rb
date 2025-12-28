# frozen_string_literal: true

module Dnd5e
  module Core
    # Represents a spell in D&D 5e.
    class Spell
      attr_reader :name, :level, :school, :casting_time, :range, :components, :duration, :description

      def initialize(**attributes)
        @name = attributes.fetch(:name)
        @level = attributes.fetch(:level)
        @school = attributes.fetch(:school)
        @casting_time = attributes.fetch(:casting_time)
        @range = attributes.fetch(:range)
        @components = attributes.fetch(:components)
        @duration = attributes.fetch(:duration)
        @description = attributes.fetch(:description)
      end
    end
  end
end
