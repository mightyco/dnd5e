# frozen_string_literal: true

require_relative '../feature'

module Dnd5e
  module Core
    module Features
      # Implementation of a generic Aura feature (e.g. Paladin Aura of Protection).
      class Aura < Feature
        attr_reader :radius, :effect_hook

        def initialize(name: 'Aura', radius: 10, effect_hook: nil)
          super(name: name)
          @radius = radius
          @effect_hook = effect_hook
        end

        def on_turn_start(context)
          # Auras generally apply to allies within radius.
          # Handled by Combat logic or individual hooks.
        end

        def apply_aura_effect(attacker, combat)
          pos = combat.grid.find_position(attacker)
          return [] unless pos

          combat.grid.combatants_within(pos, @radius).reject do |c|
            # Apply only to allies for now
            combat.enemy?(attacker, c)
          end
        end
      end
    end
  end
end
