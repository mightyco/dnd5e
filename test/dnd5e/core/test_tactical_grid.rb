# frozen_string_literal: true

require_relative '../../test_helper'
require_relative '../../../lib/dnd5e/core/point_2d'
require_relative '../../../lib/dnd5e/core/tactical_grid'

module Dnd5e
  module Core
    class TestTacticalGrid < Minitest::Test
      MockUnit = Struct.new(:name)

      def setup
        @grid = TacticalGrid.new
        @hero = MockUnit.new('Hero')
        @goblin = MockUnit.new('Goblin')
      end

      def test_point_equality
        p1 = Point2D.new(5, 10)
        p2 = Point2D.new(5, 10)
        p3 = Point2D.new(0, 0)

        assert_equal p1, p2
        refute_equal p1, p3
        assert_equal p1.hash, p2.hash
      end

      def test_placement_and_lookup
        pos = Point2D.new(10, 10)
        @grid.place(@hero, pos)

        assert @grid.occupied?(pos)
        assert_equal pos, @grid.find_position(@hero)
        assert_includes @grid.occupants[pos], @hero
      end

      def test_allows_overlapping_placement
        pos = Point2D.new(0, 0)
        @grid.place(@hero, pos)
        @grid.place(@goblin, pos)

        assert_includes @grid.occupants[pos], @hero
        assert_includes @grid.occupants[pos], @goblin
      end

      def test_movement
        p1 = Point2D.new(0, 0)
        p2 = Point2D.new(5, 5)

        @grid.place(@hero, p1)
        @grid.move(@hero, p2)

        refute @grid.occupied?(p1)
        assert @grid.occupied?(p2)
        assert_equal p2, @grid.find_position(@hero)
      end

      def test_distance_orthogonal
        p1 = Point2D.new(0, 0)
        p2 = Point2D.new(30, 0)

        assert_equal 30, @grid.distance(p1, p2)
      end

      def test_distance_diagonal_5e_rule
        # In 5e/2024, diagonal moves cost the same as orthogonal (5ft)
        # So distance is max(dx, dy)
        p1 = Point2D.new(0, 0)
        p2 = Point2D.new(15, 15)

        assert_equal 15, @grid.distance(p1, p2)
      end

      def test_distance_with_altitude
        p1 = Point2D.new(0, 0)
        p2 = Point2D.new(15, 0) # 15ft away horizontally

        # Altitude of 30ft
        assert_equal 30, @grid.distance(p1, p2, a_alt: 0, b_alt: 30)
      end

      def test_combatants_within_radius
        p_center = Point2D.new(0, 0)
        p_near = Point2D.new(10, 10) # distance 10
        p_far = Point2D.new(30, 30)  # distance 30

        @grid.place(@hero, p_near)
        @grid.place(@goblin, p_far)

        within_radius = @grid.combatants_within(p_center, 20)

        assert_includes within_radius, @hero
        refute_includes within_radius, @goblin
      end
    end
  end
end
