# frozen_string_literal: true

require 'minitest/autorun'
require_relative '../../../../lib/dnd5e/core/point_2d'
require_relative '../../../../lib/dnd5e/core/tactical_grid'
require_relative '../../../../lib/dnd5e/core/helpers/pathfinder'

module Dnd5e
  module Core
    module Helpers
      class TestPathfinder < Minitest::Test
        def setup
          @grid = TacticalGrid.new
          @pathfinder = Pathfinder.new(@grid)
        end

        def test_finds_direct_path
          start = Point2D.new(0, 0)
          goal = Point2D.new(10, 0)

          path = @pathfinder.find_path(start, goal)

          assert_equal 2, path.size
          assert_equal Point2D.new(5, 0), path[0]
          assert_equal Point2D.new(10, 0), path[1]
        end

        def test_finds_diagonal_path
          start = Point2D.new(0, 0)
          goal = Point2D.new(5, 5)

          path = @pathfinder.find_path(start, goal)

          assert_equal 1, path.size
          assert_equal Point2D.new(5, 5), path[0]
        end

        def test_returns_empty_if_blocked
          start = Point2D.new(0, 0)
          goal = Point2D.new(10, 0)

          # Mock traversable to block everything
          @grid.define_singleton_method(:traversable?) { |*_args| false }

          path = @pathfinder.find_path(start, goal)

          assert_empty path
        end
      end
    end
  end
end
