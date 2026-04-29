# frozen_string_literal: true

require_relative '../../test_helper'
require_relative '../../../lib/dnd5e/builders/character_builder'

module Dnd5e
  module Builders
    class TestPaladinBuilder < Minitest::Test
      def builder
        CharacterBuilder.new(name: 'Arthur')
      end

      def test_build_level_1_paladin
        paladin = builder.as_paladin(level: 1, abilities: { strength: 16, charisma: 14 }).build

        assert_equal 'Arthur', paladin.name
        assert_equal 1, paladin.statblock.level
      end

      def test_paladin_lv2_resources
        paladin = builder.as_paladin(level: 2).build

        assert_equal 2, paladin.statblock.resources.resources[:lvl1_slots]
      end

      def test_paladin_lv3_resources
        paladin = builder.as_paladin(level: 3).build

        assert_equal 2, paladin.statblock.resources.resources[:channel_divinity]
      end

      def test_paladin_has_divine_smite_at_level_two
        paladin = builder.as_paladin(level: 2).build

        assert(paladin.feature_manager.features.any? { |f| f.is_a?(Core::Features::DivineSmite) })
      end

      def test_paladin_has_extra_attack_at_level_five
        paladin = builder.as_paladin(level: 5).build

        assert_equal 1, paladin.statblock.extra_attacks
      end
    end
  end
end
