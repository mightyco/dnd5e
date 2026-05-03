# frozen_string_literal: true

require_relative '../../../test_helper'
require_relative '../../../../lib/dnd5e/core/helpers/pathfinder'
require_relative '../../../../lib/dnd5e/core/tactical_grid'
require_relative '../../../../lib/dnd5e/core/point_2d'

module Dnd5e
  module Core
    module Helpers
      class PathfinderAStarTest < Minitest::Test
        def setup
          @grid = TacticalGrid.new
          @pathfinder = Pathfinder.new(@grid)
          @start = Point2D.new(0, 0)
          @goal = Point2D.new(10, 10)
        end

        def test_find_path_unobstructed
          path = @pathfinder.find_path(@start, @goal)

          refute_empty path
          assert_equal @goal, path.last
          assert_equal 2, path.size # (5,5), (10,10)
        end

        def test_find_path_with_obstacle
          # Manually set a mock traversable behavior or use a temporary subclass
          # to avoid minitest/mock issues if it's not in the bundle
          grid_with_hole = Class.new(TacticalGrid) do
            def traversable?(point, _combatant = nil)
              point != Point2D.new(5, 5)
            end
          end.new

          pathfinder = Pathfinder.new(grid_with_hole)
          path = pathfinder.find_path(@start, @goal)

          refute_includes path, Point2D.new(5, 5)
          assert_equal @goal, path.last
        end

        def test_find_path_ignores_difficult_terrain_in_bfs
          @goal = Point2D.new(10, 0)
          @grid.set_terrain(Point2D.new(5, 0), :difficult)

          path = @pathfinder.find_path(@start, @goal)

          # BFS finds the path with the fewest steps.
          # (0,0) -> (5,0) -> (10,0) is 2 steps.
          # (0,0) -> (5,5) -> (10,0) is also 2 steps.
          # In BFS, it might pick either. We just ensure it finds the goal.
          assert_equal @goal, path.last
          assert_equal 2, path.size
        end
      end
    end
  end
end
