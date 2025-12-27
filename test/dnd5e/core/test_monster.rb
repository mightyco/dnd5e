# frozen_string_literal: true

# /home/chuck_mcintyre/src/dnd5e/test/dnd5e/core/test_monster.rb
require_relative '../../test_helper'
require_relative '../../../lib/dnd5e/core/monster'
require_relative '../../../lib/dnd5e/core/statblock'

module Dnd5e
  module Core
    class TestMonster < Minitest::Test
      def test_monster_creation
        statblock = Statblock.new(name: 'Goblin Statblock', hit_die: 'd10')
        monster = Monster.new(name: 'Goblin', statblock: statblock)
        assert_equal 'Goblin', monster.name
        assert_equal 10, monster.statblock.hit_points
        assert_equal 1, monster.statblock.level
        assert_equal 10, monster.statblock.charisma
        assert monster.statblock.respond_to?(:take_damage)
        assert monster.statblock.respond_to?(:heal)
        assert monster.statblock.respond_to?(:level_up)
      end

      def test_monster_uses_statblock_methods
        statblock = Statblock.new(name: 'TestStatblock', strength: 10, dexterity: 12, constitution: 14,
                                  intelligence: 8, wisdom: 16, charisma: 18, hit_die: 'd8')
        monster = Monster.new(name: 'TestMonster', statblock: statblock)
        monster.statblock.take_damage(5)
        assert_equal 5, monster.statblock.hit_points
        monster.statblock.heal(2)
        assert_equal 7, monster.statblock.hit_points
        monster.statblock.level_up
        assert_equal 2, monster.statblock.level
      end
    end
  end
end
