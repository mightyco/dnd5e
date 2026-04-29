# frozen_string_literal: true

require_relative '../../test_helper'
require_relative '../../../lib/dnd5e/builders/character_builder'

module Dnd5e
  module Builders
    class TestClericBuilder < Minitest::Test
      def builder
        CharacterBuilder.new(name: 'Pike')
      end

      def test_build_level_1_cleric
        cleric = builder.as_cleric(level: 1, abilities: { wisdom: 16 }).build

        assert_equal 'Pike', cleric.name
        assert_equal 1, cleric.statblock.level
      end

      def test_cleric_lvl1_resources
        cleric = builder.as_cleric(level: 1).build

        assert_equal 2, cleric.statblock.resources.resources[:lvl1_slots]
      end

      def test_cleric_lvl5_slots_l1
        cleric = builder.as_cleric(level: 5).build

        assert_equal 4, cleric.statblock.resources.resources[:lvl1_slots]
      end

      def test_cleric_lvl5_slots_l2
        cleric = builder.as_cleric(level: 5).build

        assert_equal 3, cleric.statblock.resources.resources[:lvl2_slots]
      end

      def test_cleric_lvl5_slots_l3
        cleric = builder.as_cleric(level: 5).build

        assert_equal 2, cleric.statblock.resources.resources[:lvl3_slots]
      end

      def test_cleric_features
        cleric = builder.as_cleric(level: 1).build

        assert(cleric.feature_manager.features.any? { |f| f.is_a?(Core::Features::DivineSpark) })
      end
    end
  end
end
