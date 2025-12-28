# frozen_string_literal: true

module Dnd5e
  module Core
    # Proficiency bonus calculations based on level.
    module Proficiency
      TABLE = {
        1..4 => 2, 5..8 => 3, 9..12 => 4, 13..16 => 5, 17..20 => 6
      }.freeze

      def self.calculate(level)
        range = TABLE.keys.find { |r| r.cover?(level) }
        raise "Invalid level: #{level}" unless range

        TABLE[range]
      end
    end
  end
end
