# frozen_string_literal: true

require_relative '../../../test_helper'
require_relative '../../../../lib/dnd5e/core/helpers/pathfinder'
require_relative '../../../../lib/dnd5e/core/tactical_grid'
require_relative '../../../../lib/dnd5e/core/point_2d'

module Dnd5e
  module Core
    module Helpers
      class PathfinderDifficultTerrainTest < Minitest::Test
        def setup
          @grid = TacticalGrid.new
          @pathfinder = Pathfinder.new(@grid)
          @start = Point2D.new(0, 0)
          @goal = Point2D.new(10, 0)
        end

        def test_prefers_cheaper_path_around_difficult_terrain
          @grid.set_terrain(Point2D.new(5, 0), :difficult)

          path = @pathfinder.find_path(@start, @goal)

          # A* should avoid (5,0) (cost 15) and pick an optimal path (cost 10).
          # Both (5,5) and (5,-5) are valid intermediate steps with cost 5.
          refute_includes path, Point2D.new(5, 0), 'Should avoid difficult terrain at (5,0)'
          assert_equal 2, path.size, 'Should find a 2-step optimal path'
          assert_equal @goal, path.last
        end
      end
    end
  end
end
