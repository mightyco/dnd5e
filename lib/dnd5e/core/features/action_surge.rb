# frozen_string_literal: true

require_relative '../feature'

module Dnd5e
  module Core
    module Features
      # Implementation of the Action Surge class feature.
      class ActionSurge < Feature
        def initialize
          super(name: 'Action Surge')
        end

        def on_turn_start(context)
          # Allows an extra action. Handled by strategy or core logic.
          # For now, we'll just track that it was used.
        end
      end
    end
  end
end
