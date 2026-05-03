# frozen_string_literal: true

module Dnd5e
  module Core
    module Strategies
      # Helper for movement-specific strategy logic.
      module MovementStrategyHelper
        private

        def move_away_from_target(combatant, target, combat)
          current_pos = combat.grid.find_position(combatant)
          target_pos = combat.grid.find_position(target)
          return unless current_pos && target_pos

          speed = combatant.turn_context.movement_available?
          best_pos = find_best_retreat_pos(combatant, current_pos, target_pos, combat)

          return unless best_pos
          return unless combat.grid.distance(best_pos, target_pos) > combat.grid.distance(current_pos, target_pos)

          apply_retreat_move(combatant, current_pos, best_pos, speed, combat)
        end

        def find_best_retreat_pos(combatant, current_pos, target_pos, combat)
          combat.grid.neighbors(current_pos)
                .select { |n| combat.grid.traversable?(n, combatant) }
                .max_by { |n| combat.grid.distance(n, target_pos) }
        end

        def apply_retreat_move(combatant, start, direction, speed, combat)
          segment, used = calculate_move_segment_away(start, direction, speed, combat)
          return if segment.empty?

          combat.move_combatant(combatant, segment)
          combatant.turn_context.use_movement(used)
        end

        def calculate_move_segment_away(start, direction, speed, combat)
          off = [direction.x - start.x, direction.y - start.y]
          segment, _curr, rem = build_away_segment(start, off, speed, combat)
          [segment, speed - rem]
        end

        def build_away_segment(start, off, speed, combat)
          segment = []
          curr = start
          rem = speed
          while rem >= 5
            curr, moved = step_away(curr, off, combat)
            break unless moved

            segment << curr
            rem -= 5
          end
          [segment, curr, rem]
        end

        def step_away(curr, off, combat)
          nxt = Point2D.new(curr.x + off[0], curr.y + off[1])
          return [nxt, true] if can_move_to?(nxt, combat)

          [curr, false]
        end

        def can_move_to?(point, combat)
          combat.grid.traversable?(point, nil) && combat.grid.can_end_at?(point)
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
          is_ranged = combatant.attacks.any? { |a| a.range > 30 }

          return dist <= 40 if is_ranged

          dist <= 5 && combatant.attacks.any? { |a| a.range > 5 }
        end
      end
    end
  end
end
