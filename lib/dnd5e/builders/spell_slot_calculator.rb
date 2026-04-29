# frozen_string_literal: true

require_relative '../core/rule_repository'

module Dnd5e
  module Builders
    # Calculates spell slots for a class based on ingested rules.
    module SpellSlotCalculator
      MULTICLASS_SLOTS = {
        1 => [2, 0, 0, 0, 0, 0, 0, 0, 0],
        2 => [3, 0, 0, 0, 0, 0, 0, 0, 0],
        3 => [4, 2, 0, 0, 0, 0, 0, 0, 0],
        4 => [4, 3, 0, 0, 0, 0, 0, 0, 0],
        5 => [4, 3, 2, 0, 0, 0, 0, 0, 0],
        6 => [4, 3, 3, 0, 0, 0, 0, 0, 0],
        7 => [4, 3, 3, 1, 0, 0, 0, 0, 0],
        8 => [4, 3, 3, 2, 0, 0, 0, 0, 0],
        9 => [4, 3, 3, 3, 1, 0, 0, 0, 0],
        10 => [4, 3, 3, 3, 2, 0, 0, 0, 0],
        11 => [4, 3, 3, 3, 2, 1, 0, 0, 0],
        12 => [4, 3, 3, 3, 2, 1, 0, 0, 0],
        13 => [4, 3, 3, 3, 2, 1, 1, 0, 0],
        14 => [4, 3, 3, 3, 2, 1, 1, 0, 0],
        15 => [4, 3, 3, 3, 2, 1, 1, 1, 0],
        16 => [4, 3, 3, 3, 2, 1, 1, 1, 0],
        17 => [4, 3, 3, 3, 2, 1, 1, 1, 1],
        18 => [4, 3, 3, 3, 3, 1, 1, 1, 1],
        19 => [4, 3, 3, 3, 3, 2, 1, 1, 1],
        20 => [4, 3, 3, 3, 3, 2, 2, 1, 1]
      }.freeze

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

      # Calculates multiclass spell slots based on 2024 rules.
      #
      # @param class_levels [Hash] A hash of class names and levels.
      # @return [Hash] A hash of spell slots.
      def self.calculate_multiclass(class_levels)
        effective_level = calculate_effective_caster_level(class_levels)
        return {} if effective_level.zero?

        slots = MULTICLASS_SLOTS[[effective_level, 20].min]
        map_slots(slots)
      end

      def self.calculate_effective_caster_level(class_levels)
        full = sum_levels(class_levels, %i[bard cleric druid sorcerer wizard])
        half = (sum_levels(class_levels, %i[paladin ranger]) / 2.0).floor.to_i
        third = (sum_levels(class_levels, %i[fighter rogue]) / 3.0).floor.to_i
        full + half + third
      end

      def self.sum_levels(class_levels, classes)
        class_levels.select { |k, _| classes.include?(k.to_sym) }.values.sum
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
