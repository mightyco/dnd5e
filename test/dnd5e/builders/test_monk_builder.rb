# frozen_string_literal: true

require_relative '../../test_helper'
require_relative '../../../lib/dnd5e/builders/character_builder'

module Dnd5e
  module Builders
    class TestMonkBuilder < Minitest::Test
      def builder
        CharacterBuilder.new(name: 'Lee')
      end

      def test_build_level_1_monk
        monk = builder.as_monk(level: 1, abilities: { dexterity: 16, wisdom: 14 }).build

        assert_equal 'Lee', monk.name
        assert_equal 15, monk.statblock.armor_class
      end

      def test_monk_lv1_features
        monk = builder.as_monk(level: 1).build

        assert(monk.feature_manager.features.any? { |f| f.is_a?(Core::Features::MartialArts) })
      end

      def test_monk_lv2_features
        monk = builder.as_monk(level: 2).build

        assert(monk.feature_manager.features.any? { |f| f.is_a?(Core::Features::FlurryOfBlows) })
      end

      def test_monk_has_extra_attack_at_level_five
        monk = builder.as_monk(level: 5).build

        assert_equal 1, monk.statblock.extra_attacks
      end
    end
  end
end
