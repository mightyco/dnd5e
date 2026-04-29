# frozen_string_literal: true

require_relative '../feature'

module Dnd5e
  module Core
    module Features
      # Implementation of the Barbarian's Path of the Wild Heart: Rage of the Wilds.
      # Feature for Barbarian Wild Heart.
      class WildHeartFeatures < Feature
        def initialize
          super(name: 'Wild Heart')
        end

        def on_damage_taken(context)
          defender = context[:defender]
          return nil unless defender.condition?(:raging)

          # 2024: Wild Heart provides extra resistance.
          # Base Rage already handles B/P/S.
          # We'll assume this feature adds resistance to everything except Force/Psychic (simplified)
          damage = context[:current_value]
          (damage / 2).to_i
        end
      end
    end
  end
end
