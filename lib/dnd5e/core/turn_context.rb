# frozen_string_literal: true

module Dnd5e
  module Core
    # Tracks the usage of actions, bonus actions, and movement during a turn.
    class TurnContext
      attr_reader :actions_used, :bonus_actions_used, :reactions_used, :movement_used

      def initialize
        reset!
      end

      # Resets the context for a new turn.
      def reset!
        @actions_used = 0
        @bonus_actions_used = 0
        @reactions_used = 0
        @movement_used = 0
      end

      def use_action
        raise 'Action already used' if @actions_used >= 1

        @actions_used += 1
      end

      def use_bonus_action
        raise 'Bonus Action already used' if @bonus_actions_used >= 1

        @bonus_actions_used += 1
      end

      def use_reaction
        raise 'Reaction already used' if @reactions_used >= 1

        @reactions_used += 1
      end

      def use_movement(feet)
        @movement_used += feet
      end

      # Checks if an action is available.
      def action_available?
        @actions_used < 1
      end

      # Checks if a bonus action is available.
      def bonus_action_available?
        @bonus_actions_used < 1
      end
    end
  end
end
