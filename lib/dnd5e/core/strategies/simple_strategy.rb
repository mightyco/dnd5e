# frozen_string_literal: true

require_relative 'base_strategy'

module Dnd5e
  module Core
    module Strategies
      # A simple strategy that attacks the first available target.
      class SimpleStrategy < BaseStrategy
        def execute_turn(combatant, combat)
          # 1. Potential Bonus Action (e.g., Second Wind)
          try_second_wind(combatant)

          # 2. Main Action
          execute_action(combatant, combat)

          # 3. Potential Action Surge
          try_action_surge(combatant, combat)
        end

        private

        def execute_action(combatant, combat)
          return unless combatant.turn_context.action_available?

          target = find_target(combatant, combat)
          return unless target

          attack = select_attack(combatant, combat)
          return unless attack

          # Move if necessary
          move_towards_target(combatant, target, attack, combat)

          # Attack if in range
          return unless in_range?(attack, combat)

          execute_attacks(combatant, target, attack, combat)
          combatant.turn_context.use_action
        end

        def move_towards_target(combatant, _target, attack, combat)
          return if in_range?(attack, combat) && !should_kite?(combatant, combat)

          speed = combatant.statblock.speed
          if should_kite?(combatant, combat)
            combat.distance += speed
          else
            combat.distance = [0, combat.distance - speed].max
          end
          combatant.turn_context.use_movement(speed)
        end

        def should_kite?(combatant, combat)
          # Kite if we have a ranged attack and the enemy is close
          return false if combat.distance > 5

          combatant.attacks.any? { |a| a.range > 5 }
        end

        def in_range?(attack, combat)
          combat.distance <= attack.range
        end

        def execute_attacks(combatant, target, attack, combat)
          num_attacks = attack.type == :save ? 1 : 1 + combatant.statblock.extra_attacks
          num_attacks.times do
            break unless target.statblock.alive?

            combat.attack(combatant, target, attack: attack)
            combatant.statblock.resources.consume(attack.resource_cost) if attack.resource_cost
          end
        end

        def select_attack(combatant, combat)
          # Select first attack that is affordable and safe (don't AOE self)
          combatant.attacks.find do |attack|
            affordable = combatant.statblock.resources.available?(attack.resource_cost)
            safe = !self_damage?(combatant, attack, combat)
            affordable && safe
          end
        end

        def self_damage?(_combatant, attack, combat)
          return false unless attack.area_radius

          # In our simple 1D engine, we are hit if distance is less than radius
          combat.distance < attack.area_radius
        end

        def try_second_wind(combatant)
          return unless combatant.statblock.resources.available?(:second_wind)
          return unless wounded?(combatant)

          heal_amount = calculate_second_wind(combatant)
          combatant.statblock.heal(heal_amount)
          combatant.statblock.resources.consume(:second_wind)
        end

        def wounded?(combatant)
          combatant.statblock.hit_points < combatant.statblock.calculate_hit_points / 2
        end

        def calculate_second_wind(combatant)
          Core::DiceRoller.new.roll("1d10+#{combatant.statblock.level}")
        end

        def try_action_surge(combatant, combat)
          return unless combatant.statblock.resources.available?(:action_surge)

          # Simple logic: use it if it's the first turn or someone is low
          combatant.statblock.resources.consume(:action_surge)
          combatant.turn_context.reset! # HACK: Resetting turn context to allow another action
          execute_action(combatant, combat)
        end

        def find_target(combatant, combat)
          # Use the combat's defender selection logic (which handles teams)
          combat.find_valid_defender(combatant)
        end
      end
    end
  end
end
