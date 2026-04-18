# frozen_string_literal: true

module Dnd5e
  module Core
    module Helpers
      # A simple BFS-based pathfinder for the 5ft square grid.
      class Pathfinder
        def initialize(grid)
          @grid = grid
        end

        # Returns an array of points from start to goal (exclusive of start).
        def find_path(start, goal, combatant = nil)
          return [] if start == goal

          queue = [[start, []]]
          visited = { start => true }

          while queue.any?
            current, path = queue.shift
            return path if current == goal

            explore_neighbors(current, path, visited, queue, combatant)
          end

          [] # No path found
        end

        private

        def explore_neighbors(current, path, visited, queue, combatant)
          sorted_neighbors(current).each do |neighbor|
            next if visited[neighbor]
            next unless @grid.traversable?(neighbor, combatant)

            visited[neighbor] = true
            queue << [neighbor, path + [neighbor]]
          end
        end

        def sorted_neighbors(point)
          @grid.neighbors(point).sort_by { |n| orthogonal?(point, n) ? 0 : 1 }
        end

        def orthogonal?(p_origin, p_target)
          p_origin.x == p_target.x || p_origin.y == p_target.y
        end
      end
    end
  end
end
