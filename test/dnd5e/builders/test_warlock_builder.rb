# frozen_string_literal: true

require_relative '../../test_helper'
require_relative '../../../lib/dnd5e/builders/character_builder'

module Dnd5e
  module Builders
    class TestWarlockBuilder < Minitest::Test
      def builder
        CharacterBuilder.new(name: 'Warly')
      end

      def test_build_level_1_warlock
        warlock = builder.as_warlock(level: 1, abilities: { charisma: 16 }).build

        assert_equal 'Warly', warlock.name
        assert_equal 1, warlock.statblock.level
      end

      def test_warlock_no_agonizing_blast_lv1
        warlock = builder.as_warlock(level: 1).build

        refute(warlock.feature_manager.features.any? { |f| f.is_a?(Core::Features::AgonizingBlast) })
      end

      def test_warlock_has_agonizing_blast_lv2
        warlock = builder.as_warlock(level: 2).build

        assert(warlock.feature_manager.features.any? { |f| f.is_a?(Core::Features::AgonizingBlast) })
      end

      def test_agonizing_blast_damage_modifier
        warlock = builder.as_warlock(level: 2, abilities: { charisma: 16 }).build
        feature = warlock.feature_manager.features.find { |f| f.is_a?(Core::Features::AgonizingBlast) }

        attack = Core::Attack.new(name: 'Eldritch Blast', damage_dice: Core::Dice.new(1, 10))
        context = { attacker: warlock, attack: attack, dice: attack.damage_dice }

        modified_dice = feature.on_damage_calculation(context)

        assert_equal 3, modified_dice.modifier
      end
    end
  end
end
