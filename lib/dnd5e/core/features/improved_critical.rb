# frozen_string_literal: true

require_relative '../feature'

module Dnd5e
  module Core
    module Features
      # Implementation of the Champion Fighter's Improved Critical feature.
      # The Champion scores a critical hit on a roll of 19 or 20.
      class ImprovedCritical < Feature
        def initialize
          super(name: 'Improved Critical')
        end

        def on_character_init(context)
          character = context[:character]
          character.statblock.crit_threshold = 19
        end
      end
    end
  end
end
