# frozen_string_literal: true

module Dnd5e
  module Core
    # Manages conditions for a combatant.
    class ConditionManager
      attr_reader :conditions

      def initialize
        @conditions = {} # Name => { source: attacker_id, expiry: :turn_end, etc. }
      end

      def add(condition_name, options = {})
        @conditions[condition_name] = options
      end

      def remove(condition_name)
        @conditions.delete(condition_name)
      end

      def active?(condition_name)
        @conditions.key?(condition_name)
      end

      def get_context(condition_name)
        @conditions[condition_name]
      end

      # Handles end-of-turn cleanup
      def end_turn
        @conditions.delete_if { |_name, options| options[:expiry] == :turn_end }
      end
    end
  end
end
