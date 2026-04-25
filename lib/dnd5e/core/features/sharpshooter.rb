# frozen_string_literal: true

require_relative '../feature'

module Dnd5e
  module Core
    module Features
      # Implementation of the Sharpshooter feat (2024).
      class Sharpshooter < Feature
        def initialize
          super(name: 'Sharpshooter')
        end

        def on_attack_roll(context)
          # 2024: No disadvantage for firing in melee range.
          context[:options][:ignore_proximity_disadvantage] = true
          0
        end

        def on_damage_taken(_context)
          # Not used for damage modification generally.
        end
      end
    end
  end
end
