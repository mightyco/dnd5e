# frozen_string_literal: true

require_relative '../feature'
module Dnd5e
  module Core
    module Features
      # Feature for Bard Cutting Words.
      class CuttingWords < Feature
        def initialize = super(name: 'Cutting Words')

        def on_after_attack_roll(context, roll_data)
          defender = context[:defender]
          return roll_data unless defender.name == 'Lore Bard'

          roll_data[:total] -= 4
          roll_data
        end
      end
    end
  end
end
