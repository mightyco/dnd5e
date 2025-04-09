require_relative "../../test_helper"
require_relative "../../../lib/dnd5e/builders/monster_builder"
require_relative "../../../lib/dnd5e/core/monster"
require_relative "../../../lib/dnd5e/core/statblock"
require_relative "../../../lib/dnd5e/core/attack"
require_relative "../../../lib/dnd5e/core/dice"

module Dnd5e
  module Builders
    class TestMonsterBuilder < Minitest::Test
      def setup
        @statblock = Core::Statblock.new(name: "Test Statblock")
        @attack = Core::Attack.new(name: "Test Attack", damage_dice: Core::Dice.new(1, 6))
      end

      def test_build_valid_monster
        monster = MonsterBuilder.new(name: "Test Monster")
                                .with_statblock(@statblock)
                                .with_attack(@attack)
                                .build

        assert_instance_of Core::Monster, monster
        assert_equal "Test Monster", monster.name
        assert_equal @statblock, monster.statblock
        assert_includes monster.attacks, @attack
      end

      def test_build_missing_name
        assert_raises MonsterBuilder::InvalidMonsterError do
          MonsterBuilder.new(name: nil).with_statblock(@statblock).build
        end
      end

      def test_build_missing_statblock
        assert_raises MonsterBuilder::InvalidMonsterError do
          MonsterBuilder.new(name: "Test Monster").build
        end
      end

      def test_with_attack
        monster_builder = MonsterBuilder.new(name: "Test Monster")
        monster_builder.with_attack(@attack)
        assert_equal 1, monster_builder.instance_variable_get(:@attacks).count
      end
    end
  end
end
