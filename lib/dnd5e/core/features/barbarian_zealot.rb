# frozen_string_literal: true

require_relative '../feature'

module Dnd5e
  module Core
    module Features
      # Implementation of the Barbarian's Zealot subclass: Divine Fury.
      # Feature for Barbarian Divine Fury.
      class DivineFury < Feature
        def initialize(level: 3)
          super(name: 'Divine Fury')
          @level = level
        end

        def on_damage_calculation(context)
          attacker = context[:attacker]
          return nil unless attacker.condition?(:raging)

          # 2024: 1d6 + Half Barbarian Level (Radiant/Necrotic)
          # In simulation, we'll just add it to the primary attack roll once per turn.
          # To simplify, we'll just add the bonus to the dice.
          dice = context[:dice]
          bonus = 3.5 + (@level / 2.0) # Average of 1d6 is 3.5
          Dice.new(dice.count, dice.sides, modifier: dice.modifier + bonus.to_i)
        end
      end
    end
  end
end
