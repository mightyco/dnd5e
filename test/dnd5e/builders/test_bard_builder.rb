# frozen_string_literal: true

require_relative '../../test_helper'
require_relative '../../../lib/dnd5e/builders/character_builder'

module Dnd5e
  module Builders
    class TestBardBuilder < Minitest::Test
      def builder
        CharacterBuilder.new(name: 'Scanlan')
      end

      def test_build_level_1_bard
        bard = builder.as_bard(level: 1, abilities: { charisma: 16 }).build

        assert_equal 'Scanlan', bard.name
        assert_equal 1, bard.statblock.level
      end

      def test_bard_lvl1_resources
        bard = builder.as_bard(level: 1).build

        assert_equal 2, bard.statblock.resources.resources[:lvl1_slots]
      end

      def test_bard_lvl5_slots_l1
        bard = builder.as_bard(level: 5).build

        assert_equal 4, bard.statblock.resources.resources[:lvl1_slots]
      end

      def test_bard_lvl5_slots_l2
        bard = builder.as_bard(level: 5).build

        assert_equal 3, bard.statblock.resources.resources[:lvl2_slots]
      end

      def test_bard_lvl5_slots_l3
        bard = builder.as_bard(level: 5).build

        assert_equal 2, bard.statblock.resources.resources[:lvl3_slots]
      end

      def test_bard_features
        bard = builder.as_bard(level: 1).build

        assert(bard.feature_manager.features.any? { |f| f.is_a?(Core::Features::BardicInspiration) })
      end

      def test_bardic_inspiration_scaling
        bard_lv5 = builder.as_bard(level: 5).build

        assert_equal 3, bard_lv5.statblock.resources.resources[:bardic_inspiration]
      end
    end
  end
end
