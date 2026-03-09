# frozen_string_literal: true

require_relative '../feature'

module Dnd5e
  module Core
    module Features
      # Implementation of the Great Weapon Master feat (2024).
      # Adds Proficiency Bonus to damage once per turn when hitting with a Heavy weapon.
      # Grants a Bonus Action attack on a crit or kill.
      class GreatWeaponMaster < Feature
        def initialize
          super(name: 'Great Weapon Master')
        end

        def on_attack_roll(_context)
          0 # No longer a penalty in 2024
        end

        def extra_damage_dice(context)
          attacker = context[:attacker]
          attack = context[:attack]

          # 2024: Once per turn, add PB to damage
          return [] unless attack.properties.include?(:heavy)
          return [] if attacker.turn_context.instance_variable_get(:@gwm_damage_used)

          attacker.turn_context.instance_variable_set(:@gwm_damage_used, true)
          [Dice.new(1, 1, modifier: attacker.statblock.proficiency_bonus - 1)] # Hack to add PB damage
        end
      end
    end
  end
end
