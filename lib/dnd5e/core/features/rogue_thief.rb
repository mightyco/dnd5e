# frozen_string_literal: true

require_relative '../feature'

module Dnd5e
  module Core
    module Features
      # Implementation of the Rogue's Thief subclass features.
      # Feature for Rogue Thief.
      class ThiefFeatures < Feature
        def initialize
          super(name: 'Thief')
        end

        def on_character_init(context)
          char = context[:character]
          # 2024: Fast Hands allows using a Bonus Action for Search or Magic actions.
          # In this simulation, we'll represent it as a speed/utility boost.
          char.statblock.speed += 10 if char.statblock.speed
        end
      end
    end
  end
end
