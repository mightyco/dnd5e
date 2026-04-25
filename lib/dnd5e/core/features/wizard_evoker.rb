# frozen_string_literal: true

require_relative '../feature'

module Dnd5e
  module Core
    module Features
      # Implementation of the Sculpt Spells (Evoker) feature.
      class SculptSpells < Feature
        def initialize
          super(name: 'Sculpt Spells')
        end

        def on_aoe_target_selection(context, targets)
          attacker = context[:attacker]
          # Evoker can choose a number of creatures equal to 1 + spell level to automatically succeed.
          # For simplicity, we'll assume they always choose all allies.
          targets.reject { |t| attacker.team && t.team == attacker.team }
        end
      end

      # Implementation of the Empowered Evocation feature.
      class EmpoweredEvocation < Feature
        def initialize
          super(name: 'Empowered Evocation')
        end

        def on_damage_taken(context)
          damage = context[:current_value]
          return damage unless context[:attack]&.type == :save

          attacker = context[:attacker]
          damage + attacker.statblock.ability_modifier(:intelligence)
        end
      end
    end
  end
end
