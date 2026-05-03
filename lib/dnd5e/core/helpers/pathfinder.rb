# frozen_string_literal: true

module Dnd5e
  module Core
    module Helpers
      # An A* pathfinder for the 5ft square grid.
      class Pathfinder
        def initialize(grid)
          @grid = grid
        end

        # Returns an array of points from start to goal (exclusive of start).
        def find_path(start, goal, combatant = nil)
          return [] if start == goal

          # node structure: [f_score, current_point, g_score]
          open_set = [[heuristic(start, goal), start, 0]]
          g_scores = { start => 0 }
          came_from = {}

          final_point = perform_search(start, goal, combatant, open_set, g_scores, came_from)
          return [] unless final_point

          reconstruct_path(came_from, final_point)
        end

        private

        # rubocop:disable Metrics/MethodLength, Metrics/ParameterLists
        def perform_search(start, goal, combatant, open_set, g_scores, came_from)
          iterations = 0
          while open_set.any?
            iterations += 1
            return nil if iterations > 200

            current_node = find_best_node(open_set)
            _, current, current_g = current_node

            return current if current == goal
            next if out_of_bounds?(current, start)

            ctx = { goal: goal, combatant: combatant, open_set: open_set, g_scores: g_scores, came_from: came_from }
            expand_node(current, current_g, ctx)
          end
          nil
        end
        # rubocop:enable Metrics/MethodLength, Metrics/ParameterLists

        def reconstruct_path(came_from, current)
          path = []
          while came_from.key?(current)
            path.unshift(current)
            current = came_from[current]
          end
          path
        end

        def out_of_bounds?(current, start)
          (current.x - start.x).abs > 100 || (current.y - start.y).abs > 100
        end

        def find_best_node(open_set)
          best_idx = 0
          best_f = open_set[0][0]

          open_set.each_with_index do |node, i|
            if node[0] < best_f
              best_f = node[0]
              best_idx = i
            end
          end

          open_set.delete_at(best_idx)
        end

        # rubocop:disable Metrics/AbcSize
        def expand_node(current, current_g, ctx)
          @grid.neighbors(current).each do |neighbor|
            next unless @grid.traversable?(neighbor, ctx[:combatant]) || neighbor == ctx[:goal]

            tentative_g = current_g + @grid.movement_cost(neighbor)
            next unless tentative_g < ctx[:g_scores].fetch(neighbor, 1_000_000)

            ctx[:came_from][neighbor] = current
            ctx[:g_scores][neighbor] = tentative_g
            f_score = tentative_g + heuristic(neighbor, ctx[:goal])
            ctx[:open_set] << [f_score, neighbor, tentative_g]
          end
        end
        # rubocop:enable Metrics/AbcSize

        # Octile heuristic for 8-way movement on a 5ft grid.
        def heuristic(point_a, point_b)
          dx = (point_a.x - point_b.x).abs
          dy = (point_a.y - point_b.y).abs
          # D&D 2024 usually uses max(dx, dy) for 5ft diagonals,
          # but we use Octile as requested in the design spec.
          # Cost is in feet (multiples of 5).
          (dx + dy) + ((Math.sqrt(2) - 2) * [dx, dy].min)
        end
      end
    end
  end
end
