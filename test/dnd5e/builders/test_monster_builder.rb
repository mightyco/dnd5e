# frozen_string_literal: true

require_relative '../../test_helper'
require_relative '../../../lib/dnd5e/builders/monster_builder'
require_relative '../../../lib/dnd5e/core/monster'
require_relative '../../../lib/dnd5e/core/statblock'
require_relative '../../../lib/dnd5e/core/attack'
require_relative '../../../lib/dnd5e/core/dice'

module Dnd5e
  module Builders
    class TestMonsterBuilder < Minitest::Test
      def setup
        @statblock = Core::Statblock.new(name: 'Test Statblock')
        @attack = Core::Attack.new(name: 'Test Attack', damage_dice: Core::Dice.new(1, 6))
      end

      def test_build_valid_monster
        monster = MonsterBuilder.new(name: 'Test Monster')
                                .with_statblock(@statblock)
                                .with_attack(@attack)
                                .build

        assert_instance_of Core::Monster, monster
        assert_equal 'Test Monster', monster.name
        assert_equal @statblock, monster.statblock
        assert_includes monster.attacks, @attack
      end

      def test_build_missing_name
        assert_raises MonsterBuilder::InvalidMonsterError do
          MonsterBuilder.new(name: nil).with_statblock(@statblock).build
        end
      end

      def test_build_empty_name
        assert_raises MonsterBuilder::InvalidMonsterError do
          MonsterBuilder.new(name: '').with_statblock(@statblock).build
        end
      end

      def test_build_missing_statblock
        assert_raises MonsterBuilder::InvalidMonsterError do
          MonsterBuilder.new(name: 'Test Monster').build
        end
      end

      def test_with_attack
        monster_builder = MonsterBuilder.new(name: 'Test Monster')
        monster_builder.with_attack(@attack)

        assert_equal 1, monster_builder.instance_variable_get(:@attacks).count
      end

      def test_as_goblin
        monster = MonsterBuilder.new(name: 'Gobby').as_goblin.build

        assert_equal 'Gobby', monster.name
        assert_equal 12, monster.statblock.armor_class
        assert_equal 'Scimitar', monster.attacks.first.name
      end

      def test_as_bugbear
        monster = MonsterBuilder.new(name: 'Buggy').as_bugbear.build

        assert_equal 'Buggy', monster.name
        assert_equal 12, monster.statblock.armor_class
        assert_equal 'Morningstar', monster.attacks.first.name
        assert_equal 1, monster.statblock.extra_attacks
      end

      def test_as_ogre
        monster = MonsterBuilder.new(name: 'Shrek').as_ogre.build

        assert_equal 'Shrek', monster.name
        assert_equal 40, monster.statblock.max_hp
      end

      def test_with_hp_and_ac_overrides
        monster = MonsterBuilder.new(name: 'Buff Gobby')
                                .as_goblin
                                .with_hp(100)
                                .with_ac(20)
                                .build

        assert_equal 100, monster.statblock.max_hp
        assert_equal 100, monster.statblock.hit_points
        assert_equal 20, monster.statblock.armor_class
      end
    end
  end
end
