# frozen_string_literal: true

require_relative '../feature'

module Dnd5e
  module Core
    module Features
      # Implementation of the Tough feat.
      class Tough < Feature
        def initialize
          super(name: 'Tough')
        end

        def on_character_init(character)
          # 2024 Rules: +2 HP per level
          character.statblock.hp_bonus_per_level += 2
          # Force recalculation
          character.statblock.max_hp = character.statblock.calculate_hit_points
          character.statblock.hit_points = character.statblock.max_hp
        end

        # Also need to handle level ups?
        # Statblock#level_up calls calculate_hit_points.
        # I should probably hook into calculate_hit_points or just add it.
      end
    end
  end
end
