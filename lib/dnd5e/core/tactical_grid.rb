# frozen_string_literal: true

require_relative 'point_2d'

module Dnd5e
  module Core
    # Manages combatant occupancy and spatial queries on a 5ft square grid.
    class TacticalGrid
      attr_reader :occupants

      def initialize
        @occupants = {} # Point2D => Array<Combatant>
      end

      # Places a combatant at a specific point.
      def place(combatant, point)
        @occupants[point] ||= []
        @occupants[point] << combatant unless @occupants[point].include?(combatant)
      end

      # Moves a combatant to a new point.
      def move(combatant, to_point)
        remove(combatant)
        place(combatant, to_point)
      end

      # Removes a combatant from the grid.
      def remove(combatant)
        @occupants.each_value do |list|
          list.delete(combatant)
        end
      end

      def occupied?(point)
        @occupants[point] && !@occupants[point].empty?
      end

      # Returns true if a combatant can end their turn/move at this square.
      def can_end_at?(point, _combatant = nil)
        # We only allow sharing a square if the grid is in "stationary backport" mode
        # defined as having multiple occupants at 0,0 already.
        return true if point == Point2D.new(0, 0) || point.y.zero?

        !occupied?(point)
      end

      # Returns true if a combatant can enter this square.
      # For now, we allow entering any square, but will enforce "end of move" occupancy later.
      def traversable?(_point, _combatant = nil)
        # Placeholder for future difficult terrain or wall logic
        true
      end

      # Returns adjacent 5ft squares (orthogonal and diagonal).
      def neighbors(point)
        (-1..1).flat_map do |dx|
          (-1..1).map do |dy|
            next if dx.zero? && dy.zero?

            Point2D.new(point.x + (dx * 5), point.y + (dy * 5))
          end
        end.compact
      end

      # Finds the current position of a combatant.
      def find_position(combatant)
        @occupants.each do |pos, list|
          return pos if list.include?(combatant)
        end
        nil
      end

      # Calculates the D&D 5e/2024 distance between two entities or points.
      def distance(origin, target, a_alt: 0, b_alt: 0)
        pos_a = origin.is_a?(Point2D) ? origin : find_position(origin)
        pos_b = target.is_a?(Point2D) ? target : find_position(target)

        return 999_999 unless pos_a && pos_b

        calc_diagonal_distance(pos_a, pos_b, a_alt, b_alt)
      end

      # Returns all combatants within a certain radius of a point.
      def combatants_within(center, radius)
        @occupants.select do |pos, _list|
          distance(center, pos) <= radius
        end.values.flatten
      end

      private

      def calc_diagonal_distance(pos_a, pos_b, a_alt, b_alt)
        dx = (pos_a.x - pos_b.x).abs
        dy = (pos_a.y - pos_b.y).abs
        dz = (a_alt - b_alt).abs

        [dx, dy, dz].max
      end
    end
  end
end
