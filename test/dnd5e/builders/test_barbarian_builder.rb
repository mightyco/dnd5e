# frozen_string_literal: true

require_relative '../../test_helper'
require_relative '../../../lib/dnd5e/builders/character_builder'

module Dnd5e
  module Builders
    class TestBarbarianBuilder < Minitest::Test
      def builder
        CharacterBuilder.new(name: 'Grog')
      end

      def test_build_level_1_barbarian
        barbarian = build_grog_with_stats(1, { strength: 16, constitution: 16, dexterity: 14 })

        assert_equal 'Grog', barbarian.name
        assert_equal 15, barbarian.statblock.armor_class
        assert_equal 15, barbarian.statblock.max_hp
      end

      def test_barbarian_rage_scaling_low
        assert_equal 2, build_grog(1).statblock.resources.resources[:rage]
      end

      def test_barbarian_rage_scaling_lv3
        assert_equal 3, build_grog(3).statblock.resources.resources[:rage]
      end

      def test_barbarian_rage_scaling_lv6
        assert_equal 4, build_grog(6).statblock.resources.resources[:rage]
      end

      def test_barbarian_rage_scaling_lv12
        assert_equal 5, build_grog(12).statblock.resources.resources[:rage]
      end

      def test_barbarian_rage_scaling_lv17
        assert_equal 6, build_grog(17).statblock.resources.resources[:rage]
      end

      def test_barbarian_has_rage_feature
        barbarian = builder.as_barbarian(level: 1).build

        assert(barbarian.feature_manager.features.any? { |f| f.is_a?(Core::Features::Rage) })
      end

      def test_barbarian_has_reckless_attack_at_level_two
        barbarian = builder.as_barbarian(level: 2).build

        assert(barbarian.feature_manager.features.any? { |f| f.is_a?(Core::Features::RecklessAttack) })
      end

      def test_barbarian_has_extra_attack_at_level_five
        barbarian = builder.as_barbarian(level: 5).build

        assert_equal 1, barbarian.statblock.extra_attacks
      end

      def test_rage_damage_bonus_low
        barb = builder.as_barbarian(level: 1).build
        rage = barb.feature_manager.features.find { |f| f.is_a?(Core::Features::Rage) }

        assert_equal 2, rage.instance_variable_get(:@damage_bonus)
      end

      def test_rage_damage_bonus_high
        barb = builder.as_barbarian(level: 9).build
        rage = barb.feature_manager.features.find { |f| f.is_a?(Core::Features::Rage) }

        assert_equal 3, rage.instance_variable_get(:@damage_bonus)
      end

      private

      def build_grog(level)
        CharacterBuilder.new(name: "Grog#{level}").as_barbarian(level: level).build
      end

      def build_grog_with_stats(level, stats)
        CharacterBuilder.new(name: 'Grog').as_barbarian(level: level, abilities: stats).build
      end
    end
  end
end
