# frozen_string_literal: true

require_relative '../../test_helper'
require_relative '../../../lib/dnd5e/builders/character_builder'

module Dnd5e
  module Builders
    class TestSorcererBuilder < Minitest::Test
      def builder
        CharacterBuilder.new(name: 'Sparky')
      end

      def test_build_level_1_sorcerer
        sorcerer = builder.as_sorcerer(level: 1, abilities: { charisma: 16 }).build

        assert_equal 'Sparky', sorcerer.name
        assert_equal 1, sorcerer.statblock.level
      end

      def test_sorcery_points_lv2
        assert_equal 2, builder.as_sorcerer(level: 2).build.statblock.resources.resources[:sorcery_points]
      end

      def test_sorcery_points_lv5
        assert_equal 5, builder.as_sorcerer(level: 5).build.statblock.resources.resources[:sorcery_points]
      end

      def test_sorcery_points_lv20
        assert_equal 20, builder.as_sorcerer(level: 20).build.statblock.resources.resources[:sorcery_points]
      end

      def test_draconic_resilience_ac
        sorcerer = builder.as_sorcerer(level: 1, abilities: { dexterity: 14 })
                          .with_feature(Core::Features::DraconicResilience.new)
                          .build

        # Draconic Resilience: 13 + Dex (2) = 15
        assert_equal 15, sorcerer.statblock.armor_class
      end

      def test_sorcerer_has_innate_sorcery
        sorcerer = builder.as_sorcerer(level: 1).build

        assert(sorcerer.feature_manager.features.any? { |f| f.is_a?(Core::Features::InnateSorcery) })
      end
    end
  end
end
