# frozen_string_literal: true

module Dnd5e
  module Core
    # Tracks limited-use resources like spell slots or class features.
    class ResourcePool
      attr_reader :resources

      def initialize(initial_resources = {})
        @resources = initial_resources
        @max_resources = initial_resources.dup
      end

      # Checks if a resource is available.
      def available?(name, amount = 1)
        return true if name.nil?
        return false unless @resources.key?(name)

        @resources[name] >= amount
      end

      # Consumes a resource.
      def consume(name, amount = 1)
        return if name.nil?
        raise "Resource #{name} not available" unless available?(name, amount)

        @resources[name] -= amount
      end

      # Sets the maximum and current value of a resource.
      def set_max(name, amount)
        @max_resources[name] = amount
        @resources[name] = amount
      end

      # Resets all resources to their maximum values (e.g., after a Long Rest).
      def reset!
        @resources = @max_resources.dup
      end
    end
  end
end
