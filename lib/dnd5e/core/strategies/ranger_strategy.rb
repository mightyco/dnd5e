# frozen_string_literal: true

require_relative 'simple_strategy'

module Dnd5e
  module Core
    module Strategies
      # Strategy for Rangers.
      class RangerStrategy < SimpleStrategy
        def initialize
          super
          @name = 'Ranger'
        end

        def execute_turn(combatant, combat)
          try_ranger_bonus_action(combatant, combat)

          target, attack = prepare_turn_data(combatant, combat)
          move_towards_target(combatant, target, attack, combat) if target && attack

          execute_action(combatant, combat)
        end

        # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
        def next_target(combatant, current_target, attack, combat)
          # 2024 Ranger: Spread 'Slow' mastery to keep as many enemies at bay as possible.
          return current_target unless attack.mastery == :slow

          # If the current target is already slowed, look for a closer threat that isn't slowed.
          threats = combat.combatants.select do |c|
            c.statblock.alive? && combat.enemy?(combatant, c) && !c.condition?(:slowed)
          end

          return current_target if threats.empty?

          # Pick the closest non-slowed threat
          best_threat = threats.min_by { |c| combat.grid.distance(combatant, c) }

          # Only switch if the new threat is dangerously close (<= 30ft) or closer than current target
          threat_dist = combat.grid.distance(combatant, best_threat)
          curr_dist = combat.grid.distance(combatant, current_target)

          return best_threat if threat_dist <= 30 || threat_dist < curr_dist

          current_target
        end

        private

        def try_ranger_bonus_action(combatant, combat)
          # Prioritize Ensnaring Strike if target is alive and not restrained
          target = find_target(combatant, combat)
          return unless target

          ensnare = combatant.feature_manager.features.find { |f| f.name == 'Ensnaring Strike' }
          return if ensnare && can_ensnare?(target, combatant) && ensnare.activate(combatant, combat)

          # Fallback to Hunter's Mark
          mark_feat = combatant.feature_manager.features.find { |f| f.name == "Hunter's Mark" }
          mark_feat&.try_activate(combatant, combat)
        end

        def can_ensnare?(target, combatant)
          !target.condition?(:restrained) && combatant.statblock.resources.available?(:lvl1_slots)
        end
        # rubocop:enable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
      end
    end
  end
end
