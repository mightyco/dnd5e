# frozen_string_literal: true

require_relative '../../test_helper'
require_relative '../../../lib/dnd5e/builders/character_builder'

module Dnd5e
  module Builders
    class TestDruidBuilder < Minitest::Test
      def builder
        CharacterBuilder.new(name: 'Keyleth')
      end

      def test_build_level_1_druid
        druid = builder.as_druid(level: 1, abilities: { wisdom: 16 }).build

        assert_equal 'Keyleth', druid.name
        assert_equal 1, druid.statblock.level
      end

      def test_druid_lvl1_resources
        druid = builder.as_druid(level: 1).build

        assert_equal 2, druid.statblock.resources.resources[:lvl1_slots]
      end

      def test_druid_lvl5_slots_l1
        druid = builder.as_druid(level: 5).build

        assert_equal 4, druid.statblock.resources.resources[:lvl1_slots]
      end

      def test_druid_lvl5_slots_l2
        druid = builder.as_druid(level: 5).build

        assert_equal 3, druid.statblock.resources.resources[:lvl2_slots]
      end

      def test_druid_lvl5_slots_l3
        druid = builder.as_druid(level: 5).build

        assert_equal 2, druid.statblock.resources.resources[:lvl3_slots]
      end

      def test_druid_features
        druid = builder.as_druid(level: 1).build

        assert(druid.feature_manager.features.any? { |f| f.is_a?(Core::Features::WildShape) })
      end

      def test_druid_wild_shape_lv2
        druid_lv2 = builder.as_druid(level: 2).build

        assert_equal 2, druid_lv2.statblock.resources.resources[:wild_shape]
      end
    end
  end
end
