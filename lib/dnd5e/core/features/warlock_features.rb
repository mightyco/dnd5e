# frozen_string_literal: true

require_relative '../feature'

module Dnd5e
  module Core
    module Features
      # Implementation of the Warlock's Agonizing Blast invocation.
      class AgonizingBlast < Feature
        def initialize
          super(name: 'Agonizing Blast')
        end

        def on_damage_calculation(context)
          attacker = context[:attacker]
          attack = context[:attack]

          return nil unless attack.name == 'Eldritch Blast'

          dice = context[:dice]
          Dice.new(dice.count, dice.sides, modifier: dice.modifier + attacker.statblock.ability_modifier(:charisma))
        end
      end

      # Implementation of the Fiend Patron's Dark One's Blessing.
      class DarkOnesBlessing < Feature
        def initialize
          super(name: "Dark One's Blessing")
        end

        def on_attack_hit(context)
          attacker = context[:attacker]
          result = context[:result]

          # Gain Temp HP when reducing hostile to 0
          return unless result[:is_dead]

          temp_hp = attacker.statblock.ability_modifier(:charisma) + attacker.statblock.level
          attacker.statblock.instance_variable_set(:@temporary_hit_points,
                                                   [attacker.statblock.temporary_hit_points, temp_hp].max)
        end
      end
    end
  end
end
