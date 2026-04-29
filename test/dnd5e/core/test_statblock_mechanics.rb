# frozen_string_literal: true

require_relative '../../test_helper'
require_relative '../../../lib/dnd5e/core/statblock'

module Dnd5e
  module Core
    class TestStatblockMechanics < Minitest::Test
      def setup
        @statblock = create_default_statblock
      end

      def test_ability_modifier
        assert_equal 0, @statblock.ability_modifier(:strength)
        assert_equal 1, @statblock.ability_modifier(:dexterity)
        assert_equal 2, @statblock.ability_modifier(:constitution)
        assert_equal(-1, @statblock.ability_modifier(:intelligence))
        assert_equal 3, @statblock.ability_modifier(:wisdom)
        assert_equal 4, @statblock.ability_modifier(:charisma)
      end

      def test_alive
        assert_predicate @statblock, :alive?
        @statblock.take_damage(@statblock.hit_points)

        assert_equal 0, @statblock.hit_points
        refute_predicate @statblock, :alive?
      end

      def test_take_damage
        @statblock.take_damage(5)

        assert_equal 5, @statblock.hit_points
        @statblock.take_damage(10)

        assert_equal 0, @statblock.hit_points
      end

      def test_heal
        @statblock.take_damage(10)
        @statblock.heal(5)

        assert_equal 5, @statblock.hit_points
        @statblock.heal(10)

        assert_equal 10, @statblock.hit_points
      end

      def test_record_damage_dealt
        @statblock.record_damage_dealt(25)

        assert_equal 25, @statblock.damage_dealt
      end

      def test_ability_modifier_invalid_ability
        assert_raises(ArgumentError) { @statblock.ability_modifier(:invalid_ability) }
      end

      def test_take_damage_negative_damage
        assert_raises(ArgumentError) { @statblock.take_damage(-5) }
      end

      def test_heal_negative_amount
        assert_raises(ArgumentError) { @statblock.heal(-5) }
      end

      def test_saving_throws
        statblock = Statblock.new(name: 'Test', dexterity: 14, intelligence: 10, level: 1,
                                  saving_throw_proficiencies: [:dexterity])

        assert_equal 4, statblock.save_modifier(:dexterity) # Mod +2, Prof +2
        assert_equal 0, statblock.save_modifier(:intelligence) # Mod 0
        assert statblock.proficient_in_save?(:dexterity)
        refute statblock.proficient_in_save?(:intelligence)
      end

      def test_barbarian_unarmored_ac
        # Manually set class levels as it's private to influence unarmored_class?
        statblock = Statblock.new(name: 'Barb', dexterity: 14, constitution: 16)
        statblock.instance_variable_set(:@class_levels, { barbarian: 1 })
        # 10 + Dex(2) + Con(3) = 15
        assert_equal 15, statblock.armor_class
      end

      private

      def create_default_statblock(options = {})
        defaults = { name: 'Test', strength: 10, dexterity: 12, constitution: 14,
                     intelligence: 8, wisdom: 16, charisma: 18, hit_die: 'd8', level: 1 }
        Statblock.new(**defaults, **options)
      end
    end
  end
end
