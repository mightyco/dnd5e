# frozen_string_literal: true

module Dnd5e
  module Core
    module Strategies
      # Targeting logic for SimpleStrategy.
      module TargetingHelper
        private

        def find_target(combatant, combat)
          combat.find_valid_defender(combatant)
        end

        def in_range?(combatant, target, attack, combat)
          return false unless target

          range = attack.respond_to?(:range) ? attack.range : 5
          combat.grid.distance(combatant, target) <= range
        end

        def self_damage?(combatant, target, attack, combat)
          return false unless attack.area_radius

          dist = combat.grid.distance(combatant, target)
          dist < attack.area_radius
        end
      end
    end
  end
end
