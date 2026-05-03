# frozen_string_literal: true

require_relative '../helpers/pathfinder'
require_relative 'extra_attack_helper'
require_relative 'targeting_helper'

module Dnd5e
  module Core
    module Strategies
      # Helper logic for SimpleStrategy to keep the main class small.
      # rubocop:disable Metrics/ModuleLength
      module SimpleStrategyLogic
        include ExtraAttackHelper
        include TargetingHelper

        private

        def move_towards_target(combatant, target, attack, combat)
          return unless combatant.turn_context.movement_available?.positive?

          if in_range?(combatant, target, attack, combat) && should_kite?(combatant, target, combat)
            return move_away_from_target(combatant, target, combat)
          end

          return if in_range?(combatant, target, attack, combat)

          target_pos = combat.grid.find_position(target)
          current_pos = combat.grid.find_position(combatant)
          return unless target_pos && current_pos

          execute_grid_move(combatant, current_pos, target_pos, combatant.turn_context.movement_available?, combat)
        end

        # rubocop:disable Metrics/MethodLength, Metrics/AbcSize, Metrics/CyclomaticComplexity
        def move_away_from_target(combatant, target, combat)
          current_pos = combat.grid.find_position(combatant)
          target_pos = combat.grid.find_position(target)
          return unless current_pos && target_pos

          # Find the neighbor that maximizes distance from target
          speed = combatant.turn_context.movement_available?

          # Strategy: Check all neighbors, pick the one furthest from target
          best_pos = combat.grid.neighbors(current_pos).select { |n| combat.grid.traversable?(n, combatant) }
                           .max_by { |n| combat.grid.distance(n, target_pos) }

          return unless best_pos
          return unless combat.grid.distance(best_pos, target_pos) > combat.grid.distance(current_pos, target_pos)

          # Move as far as possible in that direction
          segment, used = calculate_move_segment_away(current_pos, best_pos, speed, combat)
          return if segment.empty?

          combat.move_combatant(combatant, segment)
          combatant.turn_context.use_movement(used)
        end
        # rubocop:enable Metrics/MethodLength, Metrics/AbcSize, Metrics/CyclomaticComplexity

        # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
        def calculate_move_segment_away(start, direction, speed, combat)
          remaining = speed
          segment = []
          curr = start
          dx = direction.x - start.x
          dy = direction.y - start.y

          while remaining >= 5
            nxt = Point2D.new(curr.x + dx, curr.y + dy)
            break unless combat.grid.traversable?(nxt, nil) && combat.grid.can_end_at?(nxt)

            segment << nxt
            curr = nxt
            remaining -= 5
          end
          [segment, speed - remaining]
        end
        # rubocop:enable Metrics/MethodLength, Metrics/AbcSize

        def execute_grid_move(combatant, _cur_pos, target_pos, speed, combat)
          path = Helpers::Pathfinder.new(combat.grid).find_path(combat.grid.find_position(combatant), target_pos)
          if path.empty?
            combatant.turn_context.use_movement(speed)
            return
          end

          trim_path_for_occupancy(path, target_pos, combat.grid)
          apply_move_segment(combatant, path, speed, combat)
        end

        def trim_path_for_occupancy(path, target_pos, grid)
          path.pop if path.last == target_pos && grid.occupied?(target_pos)
        end

        def apply_move_segment(combatant, path, speed, combat)
          segment, used = calculate_move_segment(path, speed, combat.grid)
          return if segment.empty?

          combat.move_combatant(combatant, segment)
          combatant.turn_context.use_movement(used)
        end

        def calculate_move_segment(path, speed, grid)
          remaining = speed
          segment = []
          path.each do |point|
            cost = grid.movement_cost(point)
            break if cost > remaining

            segment << point
            remaining -= cost
          end
          [segment, speed - remaining]
        end

        def should_kite?(combatant, target, combat)
          dist = combat.grid.distance(combatant, target)
          # Proactive Kiting: Always maintain at least 40ft if using a long-range weapon.
          # This keeps us outside of normal movement + melee range.
          is_ranged = combatant.attacks.any? { |a| a.range > 30 }

          return dist <= 40 if is_ranged

          # Standard kiting for others
          dist <= 5 && combatant.attacks.any? { |a| a.range > 5 }
        end

        def execute_attacks(combatant, target, attack, combat)
          num_attacks = attack.type == :save ? 1 : 1 + combatant.statblock.extra_attacks
          perform_attack_sequence(num_attacks, combatant, target, attack, combat)
          try_extra_attacks(combatant, target, attack, combat)
        end

        def perform_attack_sequence(num, combatant, target, attack, combat)
          num.times do
            # Re-acquire target if current one is dead or if strategy prefers a different one
            target = determine_best_target(combatant, target, attack, combat)
            break unless target

            execute_sequence_attack(combatant, target, attack, combat)
            try_cleave_attack(combatant, target, attack, combat)
          end
        end

        def determine_best_target(combatant, current_target, attack, combat)
          return find_target(combatant, combat) if current_target.nil? || !current_target.statblock.alive?

          # Strategy hook for subclasses to change targets between extra attacks
          if combatant.strategy.respond_to?(:next_target)
            return combatant.strategy.next_target(combatant, current_target, attack, combat)
          end

          current_target
        end

        def execute_sequence_attack(combatant, target, attack, combat)
          combat.attack(combatant, target, attack: attack)
          combatant.statblock.resources.consume(attack.resource_cost) if attack.resource_cost
        end

        def select_attack(combatant, target, combat)
          nick = combatant.attacks.find { |a| a.mastery == :nick }
          return nick if nick && combatant.statblock.resources.available?(nick.resource_cost)

          combatant.attacks.find do |attack|
            combatant.statblock.resources.available?(attack.resource_cost) &&
              !self_damage?(combatant, target, attack, combat)
          end
        end

        def try_second_wind(combatant, combat)
          return unless second_wind_available?(combatant)

          combatant.statblock.resources.consume(:second_wind)
          combat.notify_observers(:resource_used, { combatant: combatant, resource: :second_wind })
          heal_combatant(combatant)
        end

        def second_wind_available?(combatant)
          combatant.statblock.resources.available?(:second_wind) &&
            combatant.statblock.hit_points < combatant.statblock.calculate_hit_points / 2
        end

        def heal_combatant(combatant)
          combatant.statblock.heal(DiceRoller.new.roll("1d10+#{combatant.statblock.level}"))
        end

        def try_action_surge(combatant, combat)
          return unless combatant.statblock.resources.available?(:action_surge)

          combatant.statblock.resources.consume(:action_surge)
          combat.notify_observers(:resource_used, { combatant: combatant, resource: :action_surge })

          # 2024: Action Surge grants one additional action.
          original_actions = combatant.turn_context.instance_variable_get(:@actions_used)
          combatant.turn_context.instance_variable_set(:@actions_used, 0)
          execute_action(combatant, combat)
          combatant.turn_context.instance_variable_set(:@actions_used, original_actions + 1)
        end
      end
      # rubocop:enable Metrics/ModuleLength
    end
  end
end
