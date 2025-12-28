# frozen_string_literal: true

require_relative '../../test_helper'
require_relative '../../../lib/dnd5e/core/statblock'

module Dnd5e
  module Core
    class TestStatblock < Minitest::Test
      def setup
        @statblock = create_default_statblock
      end

      def test_initialize
        assert_equal 'Test', @statblock.name
        assert_equal 10, @statblock.strength
        assert_equal 10, @statblock.hit_points # (8 + 2)
        assert_equal 11, @statblock.armor_class
        assert_equal 1, @statblock.level
      end

      def test_initalize_with_defaults
        statblock = Statblock.new(name: 'Test')

        assert_equal 10, statblock.strength
        assert_equal 1, statblock.level
        assert_equal 'd8', statblock.hit_die
        assert_equal 10, statblock.armor_class
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

      def test_calculate_hit_points
        assert_equal 10, @statblock.calculate_hit_points
        assert_equal 17, create_default_statblock(level: 2).calculate_hit_points
        # d12 (12) + Con (2) = 14 base. Level 3: 14 + 9 + 9 = 32.
        assert_equal 32, create_default_statblock(hit_die: 'd12', level: 3).calculate_hit_points
      end

      def test_level_up
        statblock = create_default_statblock(level: 2)
        statblock.take_damage(10)

        assert_equal 7, statblock.hit_points
        statblock.level_up

        assert_equal 3, statblock.level
        assert_equal 24, statblock.hit_points
      end

      def test_proficiency_bonus
        { 1 => 2, 5 => 3, 9 => 4, 13 => 5, 17 => 6 }.each do |level, expected_bonus|
          statblock = create_default_statblock(level: level)

          assert_equal expected_bonus, statblock.proficiency_bonus
        end
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

      def test_deep_copy
        copied_statblock = @statblock.deep_copy

        assert_equal @statblock.name, copied_statblock.name
        assert_equal @statblock.hit_points, copied_statblock.hit_points
        refute_same @statblock, copied_statblock
        %i[strength dexterity constitution intelligence wisdom charisma].each do |stat|
          assert_equal @statblock.public_send(stat), copied_statblock.public_send(stat)
        end
      end

      def test_saving_throws
        statblock = Statblock.new(name: 'Test', dexterity: 14, intelligence: 10, level: 1,
                                  saving_throw_proficiencies: [:dexterity])

        assert_equal 4, statblock.save_modifier(:dexterity) # Mod +2, Prof +2
        assert_equal 0, statblock.save_modifier(:intelligence) # Mod 0
        assert statblock.proficient_in_save?(:dexterity)
        refute statblock.proficient_in_save?(:intelligence)
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
