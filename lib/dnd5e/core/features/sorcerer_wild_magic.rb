# frozen_string_literal: true

require_relative '../feature'
module Dnd5e
  module Core
    module Features
      # Feature for Sorcerer Tides of Chaos.
      class TidesOfChaos < Feature
        def initialize = super(name: 'Tides of Chaos')

        def on_after_attack_roll(_context, roll_data)
          roll_data[:advantage] = true if rand < 0.1
          roll_data
        end
      end
    end
  end
end
