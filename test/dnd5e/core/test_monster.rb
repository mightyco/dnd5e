# /home/chuck_mcintyre/src/dnd5e/test/dnd5e/core/test_monster.rb
require_relative "../../test_helper"
require_relative "../../../lib/dnd5e/core/monster"
require_relative "../../../lib/dnd5e/core/statblock"

module Dnd5e
  module Core
    class TestMonster < Minitest::Test
      def test_monster_creation
        statblock = Statblock.new(name: "Goblin Statblock", hit_die: "d10")
        monster = Monster.new(name: "Goblin", statblock: statblock)
        assert_equal "Goblin", monster.name
        assert_equal 10, monster.statblock.hit_points
        assert_equal 1, monster.statblock.level
        assert_equal 10, monster.statblock.charisma
        assert monster.statblock.respond_to?(:take_damage)
        assert monster.statblock.respond_to?(:heal)
        assert monster.statblock.respond_to?(:level_up)
      end
    end
  end
end
