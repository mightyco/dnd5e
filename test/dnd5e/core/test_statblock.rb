require_relative "../../test_helper"
require_relative "../../../lib/dnd5e/core/statblock" #
require 'minitest/mock'

module Dnd5e
  module Core
    class TestStatblock < Minitest::Test
      def test_initialize
        statblock = Statblock.new(name: "Test", strength: 10, dexterity: 12, constitution: 14, intelligence: 8, wisdom: 16, charisma: 18, hit_points: 20, armor_class: 15)
        assert_equal "Test", statblock.name
        assert_equal 10, statblock.strength
        assert_equal 12, statblock.dexterity
        assert_equal 14, statblock.constitution
        assert_equal 8, statblock.intelligence
        assert_equal 16, statblock.wisdom
        assert_equal 18, statblock.charisma
        assert_equal 20, statblock.hit_points
        assert_equal 15, statblock.armor_class
      end

      def test_ability_modifier
        statblock = Statblock.new(name: "Test", strength: 10, dexterity: 12, constitution: 14, intelligence: 8, wisdom: 16, charisma: 18, hit_points: 20, armor_class: 15)
        assert_equal 0, statblock.ability_modifier(:strength)
        assert_equal 1, statblock.ability_modifier(:dexterity)
        assert_equal 2, statblock.ability_modifier(:constitution)
        assert_equal -1, statblock.ability_modifier(:intelligence)
        assert_equal 3, statblock.ability_modifier(:wisdom)
        assert_equal 4, statblock.ability_modifier(:charisma)
      end

      def test_is_alive
        statblock = Statblock.new(name: "Test", strength: 10, dexterity: 12, constitution: 14, intelligence: 8, wisdom: 16, charisma: 18, hit_points: 20, armor_class: 15)
        assert statblock.is_alive?
        statblock.take_damage(20)
        assert_equal 0, statblock.hit_points
        assert_equal false, statblock.is_alive?
      end

      def test_take_damage
        statblock = Statblock.new(name: "Test", strength: 10, dexterity: 12, constitution: 14, intelligence: 8, wisdom: 16, charisma: 18, hit_points: 20, armor_class: 15)
        statblock.take_damage(5)
        assert_equal 15, statblock.hit_points
        statblock.take_damage(10)
        assert_equal 5, statblock.hit_points
      end
    end
  end
end
