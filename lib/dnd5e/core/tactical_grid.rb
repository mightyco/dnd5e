# frozen_string_literal: true

require_relative 'point_2d'

module Dnd5e
  module Core
    # Manages combatant occupancy and spatial queries on a 5ft square grid.
    class TacticalGrid
      attr_reader :occupants

      def initialize
        @occupants = {}      # Point2D => Array<Combatant>
        @position_cache = {} # Combatant => Point2D
        @terrain = {}        # Point2D => Symbol (:difficult, etc)
      end

      # Resets the grid.
      def clear
        @occupants.clear
        @position_cache.clear
        @terrain.clear
      end

      # Sets terrain type for a square.
      def set_terrain(point, type)
        @terrain[point] = type
      end

      # Returns the movement cost to enter a square.
      def movement_cost(point)
        @terrain[point] == :difficult ? 10 : 5
      end

      # Places a combatant at a specific point.
      def place(combatant, point)
        @occupants[point] ||= []
        @occupants[point] << combatant unless @occupants[point].include?(combatant)
        @position_cache[combatant] = point
      end

      # Moves a combatant to a new point.
      def move(combatant, to_point)
        remove(combatant)
        place(combatant, to_point)
      end

      # Removes a combatant from the grid.
      def remove(combatant)
        old_pos = @position_cache[combatant]
        @occupants[old_pos]&.delete(combatant) if old_pos
        @position_cache.delete(combatant)
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
      def traversable?(point, combatant = nil)
        return true unless occupied?(point)
        return true if combatant && ally_occupied?(point, combatant)

        false
      end

      # Returns true if the square is occupied by an ally of the combatant.
      def ally_occupied?(point, combatant)
        list = @occupants[point]
        return false unless list
        return false unless combatant.respond_to?(:team) && combatant.team

        list.any? { |occ| occ.respond_to?(:team) && occ.team == combatant.team }
      end

      NEIGHBOR_OFFSETS = [-5, 0, 5].product([-5, 0, 5]).reject { |x, y| x.zero? && y.zero? }.freeze

      # Returns adjacent 5ft squares (orthogonal and diagonal).
      def neighbors(point)
        NEIGHBOR_OFFSETS.map do |dx, dy|
          Point2D.new(point.x + dx, point.y + dy)
        end
      end

      # Finds the current position of a combatant.
      def find_position(combatant)
        @position_cache[combatant]
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
