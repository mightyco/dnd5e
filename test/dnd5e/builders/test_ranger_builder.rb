# frozen_string_literal: true

require_relative '../../test_helper'
require_relative '../../../lib/dnd5e/builders/character_builder'

module Dnd5e
  module Builders
    class TestRangerBuilder < Minitest::Test
      def builder
        CharacterBuilder.new(name: 'Drizzt')
      end

      def test_build_level_1_ranger
        ranger = builder.as_ranger(level: 1, abilities: { dexterity: 16 }).build

        assert_equal 'Drizzt', ranger.name
        assert_equal 1, ranger.statblock.level
      end

      def test_ranger_lv1_resources
        ranger = builder.as_ranger(level: 1).build

        assert_equal 2, ranger.statblock.resources.resources[:lvl1_slots]
      end

      def test_ranger_lv5_resources
        ranger = builder.as_ranger(level: 5).build

        assert_equal 4, ranger.statblock.resources.resources[:lvl1_slots]
        assert_equal 2, ranger.statblock.resources.resources[:lvl2_slots]
      end

      def test_ranger_features
        ranger = builder.as_ranger(level: 1).build

        assert(ranger.feature_manager.features.any? { |f| f.is_a?(Core::Features::HuntersMark) })
      end

      def test_ranger_has_extra_attack_at_level_five
        ranger = builder.as_ranger(level: 5).build

        assert_equal 1, ranger.statblock.extra_attacks
      end
    end
  end
end
