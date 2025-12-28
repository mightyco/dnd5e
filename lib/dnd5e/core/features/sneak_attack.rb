# frozen_string_literal: true

require_relative '../feature'

module Dnd5e
  module Core
    module Features
      # Implementation of the Sneak Attack class feature.
      class SneakAttack < Feature
        attr_reader :dice_count

        def initialize(dice_count: 1)
          super(name: 'Sneak Attack')
          @dice_count = dice_count
        end

        def extra_damage_dice(context)
          return [] unless eligible?(context)

          [Dice.new(@dice_count, 6)]
        end

        private

        def eligible?(context)
          # 1. Weapon must be finesse or ranged (simplified: any weapon for now)
          # 2. Must have advantage OR an ally must be near (simplified: check advantage flag)
          context[:options][:advantage] || context[:options][:sneak_attack]
        end
      end
    end
  end
end
