require_relative "../../test_helper"
require_relative "../../../lib/dnd5e/core/character"
require_relative "../../../lib/dnd5e/core/statblock"
require 'minitest/mock'

module Dnd5e
  module Core
    class TestCharacter < Minitest::Test
      def test_initialize
        statblock = Statblock.new(name: "Test", strength: 10, dexterity: 12, constitution: 14, intelligence: 8, wisdom: 16, charisma: 18, hit_die: "d8")
        character = Character.new(name: "Test", statblock: statblock)
        assert_equal "Test", character.name
        assert_equal 1, character.level
        assert_equal statblock, character.statblock
      end

      def test_proficiency_bonus
        statblock = Statblock.new(name: "Test", strength: 10, dexterity: 12, constitution: 14, intelligence: 8, wisdom: 16, charisma: 18, hit_die: "d8")
        character = Character.new(name: "Test", statblock: statblock, level: 1)
        assert_equal 2, character.proficiency_bonus
        character = Character.new(name: "Test", statblock: statblock, level: 5)
        assert_equal 3, character.proficiency_bonus
        character = Character.new(name: "Test", statblock: statblock, level: 9)
        assert_equal 4, character.proficiency_bonus
        character = Character.new(name: "Test", statblock: statblock, level: 13)
        assert_equal 5, character.proficiency_bonus
        character = Character.new(name: "Test", statblock: statblock, level: 17)
        assert_equal 6, character.proficiency_bonus
      end

      def test_level_up
        statblock = Statblock.new(name: "Test", strength: 10, dexterity: 12, constitution: 14, intelligence: 8, wisdom: 16, charisma: 18, hit_die: "d8")
        character = Character.new(name: "Test", statblock: statblock, level: 1)
        assert_equal 1, character.level
        assert_equal 10, character.max_hit_points
        character.level_up
        assert_equal 2, character.level
        assert_equal 17, character.max_hit_points
        character.level_up
        assert_equal 3, character.level
        assert_equal 24, character.statblock.hit_points
      end
    end
  end
end
