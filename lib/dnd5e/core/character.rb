module Dnd5e
  module Core
    class Character
      attr_reader :name, :level, :statblock

      def initialize(name:, statblock:, level: 1)
        @name = name
        @statblock = statblock
        @level = level
      end

      def max_hit_points
        return statblock.calculate_hit_points(@level)
      end

      def proficiency_bonus
        # Proficiency bonus increases with level
        case @level
        when 1..4
          2
        when 5..8
          3
        when 9..12
          4
        when 13..16
          5
        when 17..20
          6
        else
          raise "Invalid level"
        end
      end

      def level_up
        @level += 1
        @statblock.heal(@statblock.calculate_hit_points(@level) - @statblock.hit_points)
      end
    end
  end
end
