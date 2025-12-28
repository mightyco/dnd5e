# frozen_string_literal: true

require_relative '../feature'

module Dnd5e
  module Core
    module Features
      # Implementation of the Great Weapon Master feat.
      class GreatWeaponMaster < Feature
        def initialize
          super(name: 'Great Weapon Master')
        end

        def on_attack_roll(context)
          return -5 if context[:options][:great_weapon_master]

          0
        end

        def on_damage_calculation(context)
          return nil unless context[:options][:great_weapon_master]

          dice = context[:dice]
          Dice.new(dice.count, dice.sides, modifier: dice.modifier + 10)
        end
      end
    end
  end
end
