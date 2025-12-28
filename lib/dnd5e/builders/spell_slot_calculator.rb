# frozen_string_literal: true

require_relative '../core/rule_repository'

module Dnd5e
  module Builders
    # Calculates spell slots for a class based on ingested rules.
    module SpellSlotCalculator
      # Calculates spell slots for a given class and level.
      #
      # @param class_name [String] The name of the class (e.g., "Wizard").
      # @param level [Integer] The level of the character.
      # @return [Hash] A hash of spell slots (e.g., { lvl1_slots: 4, lvl2_slots: 3 }).
      def self.calculate(class_name, level)
        table = Core::RuleRepository.instance.class_tables[class_name.to_sym]
        return {} unless table

        row = table.find { |r| r[:level] == level }
        return {} unless row && row[:slots]

        map_slots(row[:slots])
      end

      def self.map_slots(slots)
        slots.each_with_index.with_object({}) do |(count, index), hash|
          next if count.zero?

          key = :"lvl#{index + 1}_slots"
          hash[key] = count
        end
      end
    end
  end
end
