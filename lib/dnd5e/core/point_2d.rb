# frozen_string_literal: true

module Dnd5e
  module Core
    # A simple 2D coordinate on the tactical grid (integer-based 5ft squares).
    class Point2D
      attr_reader :x, :y

      def initialize(x_coord, y_coord)
        @x = x_coord.to_i
        @y = y_coord.to_i
      end

      def ==(other)
        other.is_a?(Point2D) && x == other.x && y == other.y
      end
      alias eql? ==

      def hash
        [x, y].hash
      end

      def to_s
        "(#{@x}, #{@y})"
      end

      def inspect
        "#<Point2D x:#{@x} y:#{@y}>"
      end
    end
  end
end
