# frozen_string_literal: true

require_relative '../feature'

module Dnd5e
  module Core
    module Features
      # Implementation of the Sharpshooter feat.
      class Sharpshooter < Feature
        def initialize
          super(name: 'Sharpshooter')
        end

        def on_attack_roll(context)
          return -5 if context[:options][:sharpshooter]

          0
        end

        def on_damage_calculation(context)
          return nil unless context[:options][:sharpshooter]

          dice = context[:dice]
          Dice.new(dice.count, dice.sides, modifier: dice.modifier + 10)
        end
      end
    end
  end
end
