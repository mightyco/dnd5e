# /home/chuck_mcintyre/src/dnd5e/test/dnd5e/core/test_statblock.rb
require_relative "../../test_helper"
require_relative "../../../lib/dnd5e/core/statblock"
require 'minitest/mock'

module Dnd5e
  module Core
    class TestStatblock < Minitest::Test
      def test_initialize
        statblock = Statblock.new(name: "Test", strength: 10, dexterity: 12, constitution: 14, intelligence: 8, wisdom: 16, charisma: 18, hit_die: "d8")
        assert_equal "Test", statblock.name
        assert_equal 10, statblock.strength
        assert_equal 12, statblock.dexterity
        assert_equal 14, statblock.constitution
        assert_equal 8, statblock.intelligence
        assert_equal 16, statblock.wisdom
        assert_equal 18, statblock.charisma
        assert_equal 10, statblock.hit_points # (8 + 2)
        assert_equal 11, statblock.armor_class
        assert_equal 1, statblock.level
      end

      def test_initalize_with_defaults
        statblock = Statblock.new(name: "Test")
        assert_equal "Test", statblock.name
        assert_equal 10, statblock.strength
        assert_equal 10, statblock.dexterity
        assert_equal 10, statblock.constitution
        assert_equal 10, statblock.intelligence
        assert_equal 10, statblock.wisdom
        assert_equal 10, statblock.charisma
        assert_equal 1, statblock.level
        assert_equal "d8", statblock.hit_die
        assert_equal 8, statblock.hit_points
        assert_equal 10, statblock.armor_class
      end

      def test_ability_modifier
        statblock = Statblock.new(name: "Test", strength: 10, dexterity: 12, constitution: 14, intelligence: 8, wisdom: 16, charisma: 18, hit_die: "d8")
        assert_equal 0, statblock.ability_modifier(:strength)
        assert_equal 1, statblock.ability_modifier(:dexterity)
        assert_equal 2, statblock.ability_modifier(:constitution)
        assert_equal -1, statblock.ability_modifier(:intelligence)
        assert_equal 3, statblock.ability_modifier(:wisdom)
        assert_equal 4, statblock.ability_modifier(:charisma)

        statblock = Statblock.new(name: "Test2", strength: 10, dexterity: 12, constitution: 14, intelligence: 9, wisdom: 16, charisma: 18, hit_die: "d8")
        assert_equal -1, statblock.ability_modifier(:intelligence)
      end

      def test_is_alive
        statblock = Statblock.new(name: "Test", strength: 10, dexterity: 12, constitution: 14, intelligence: 9, wisdom: 16, charisma: 18, hit_die: "d8")
        assert statblock.is_alive?
        statblock.take_damage(statblock.hit_points)
        assert_equal 0, statblock.hit_points
        assert_equal false, statblock.is_alive?
      end

      def test_take_damage
        statblock = Statblock.new(name: "Test", strength: 10, dexterity: 12, constitution: 14, intelligence: 8, wisdom: 16, charisma: 18, hit_die: "d8")
        statblock.take_damage(5)
        assert_equal 5, statblock.hit_points
        statblock.take_damage(10)
        assert_equal 0, statblock.hit_points
      end

      def test_heal
        statblock = Statblock.new(name: "Test", strength: 10, dexterity: 12, constitution: 14, intelligence: 8, wisdom: 16, charisma: 18, hit_die: "d8")
        statblock.take_damage(10)
        statblock.heal(5)
        assert_equal 5, statblock.hit_points
        statblock.heal(10)
        assert_equal 10, statblock.hit_points
      end

      def test_calculate_hit_points
        statblock = Statblock.new(name: "Test", strength: 10, dexterity: 12, constitution: 14, intelligence: 8, wisdom: 16, charisma: 18, hit_die: "d8", level: 1)
        assert_equal 10, statblock.calculate_hit_points
        statblock = Statblock.new(name: "Test", strength: 10, dexterity: 12, constitution: 14, intelligence: 8, wisdom: 16, charisma: 18, hit_die: "d8", level: 2)
        assert_equal 17, statblock.calculate_hit_points
      end

      def test_level_up
        statblock = Statblock.new(name: "Test", strength: 10, dexterity: 12, constitution: 14, intelligence: 8, wisdom: 16, charisma: 18, hit_die: "d8", level: 2)
        statblock.take_damage(10)
        assert_equal 7, statblock.hit_points
        statblock.level_up
        assert_equal 3, statblock.level
        assert_equal 24, statblock.hit_points
      end

      def test_proficiency_bonus
        statblock = Statblock.new(name: "Test", strength: 10, dexterity: 12, constitution: 14, intelligence: 8, wisdom: 16, charisma: 18, hit_die: "d8", level: 1)
        assert_equal 2, statblock.proficiency_bonus
        statblock = Statblock.new(name: "Test", strength: 10, dexterity: 12, constitution: 14, intelligence: 8, wisdom: 16, charisma: 18, hit_die: "d8", level: 5)
        assert_equal 3, statblock.proficiency_bonus
        statblock = Statblock.new(name: "Test", strength: 10, dexterity: 12, constitution: 14, intelligence: 8, wisdom: 16, charisma: 18, hit_die: "d8", level: 9)
        assert_equal 4, statblock.proficiency_bonus
        statblock = Statblock.new(name: "Test", strength: 10, dexterity: 12, constitution: 14, intelligence: 8, wisdom: 16, charisma: 18, hit_die: "d8", level: 13)
        assert_equal 5, statblock.proficiency_bonus
        statblock = Statblock.new(name: "Test", strength: 10, dexterity: 12, constitution: 14, intelligence: 8, wisdom: 16, charisma: 18, hit_die: "d8", level: 17)
        assert_equal 6, statblock.proficiency_bonus
      end

      def test_ability_modifier_invalid_ability
        statblock = Statblock.new(name: "Test")
        assert_raises ArgumentError do
          statblock.ability_modifier(:invalid_ability)
        end
      end

      def test_take_damage_negative_damage
        statblock = Statblock.new(name: "Test")
        assert_raises ArgumentError do
          statblock.take_damage(-5)
        end
      end

      def test_heal_negative_amount
        statblock = Statblock.new(name: "Test")
        assert_raises ArgumentError do
          statblock.heal(-5)
        end
      end
    end
  end
end
