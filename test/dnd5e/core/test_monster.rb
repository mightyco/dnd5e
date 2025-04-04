# /home/chuck_mcintyre/src/dnd5e/test/dnd5e/core/test_monster.rb
require_relative "../../test_helper"
require_relative "../../../lib/dnd5e/core/monster"

module Dnd5e
  module Core
    class TestMonster < Minitest::Test
      def test_monster_inherits_from_statblock
        monster = Monster.new(name: "Goblin", hit_die: "d10")
        assert_equal "Goblin", monster.name
        assert_equal 10, monster.hit_points
        assert_equal 1, monster.level
        assert_equal 10, monster.charisma
        assert monster.respond_to?(:take_damage)
        assert monster.respond_to?(:heal)
        assert monster.respond_to?(:level_up)
      end
    end
  end
end
