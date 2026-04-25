# frozen_string_literal: true

require_relative '../feature'

module Dnd5e
  module Core
    module Features
      # Implementation of the Second Wind class feature.
      class SecondWind < Feature
        def initialize
          super(name: 'Second Wind')
        end

        def on_turn_start(context)
          # Fighter can use a bonus action to regain HP.
          # 1d10 + Fighter Level.
          # Handled by strategy.
        end
      end
    end
  end
end
