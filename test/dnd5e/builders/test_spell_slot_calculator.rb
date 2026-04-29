# frozen_string_literal: true

require_relative '../../test_helper'
require_relative '../../../lib/dnd5e/builders/spell_slot_calculator'

module Dnd5e
  module Builders
    class TestSpellSlotCalculator < Minitest::Test
      def test_calculate_multiclass_full_casters
        levels = { wizard: 3, cleric: 2 }
        # Effective level 5
        res = SpellSlotCalculator.calculate_multiclass(levels)

        assert_equal 4, res[:lvl1_slots]
        assert_equal 3, res[:lvl2_slots]
        assert_equal 2, res[:lvl3_slots]
      end

      def test_calculate_multiclass_half_casters
        levels = { paladin: 2, ranger: 2 }
        # Effective level (2/2) + (2/2) = 2
        res = SpellSlotCalculator.calculate_multiclass(levels)

        assert_equal 3, res[:lvl1_slots]
      end

      def test_calculate_multiclass_mixed
        levels = { wizard: 2, paladin: 2 }
        # Effective level 2 + (2/2) = 3
        res = SpellSlotCalculator.calculate_multiclass(levels)

        assert_equal 4, res[:lvl1_slots]
        assert_equal 2, res[:lvl2_slots]
      end

      def test_calculate_multiclass_three_classes
        levels = { wizard: 1, cleric: 1, paladin: 2 }
        # Effective: 1 + 1 + (2/2) = 3
        res = SpellSlotCalculator.calculate_multiclass(levels)

        assert_equal 4, res[:lvl1_slots]
        assert_equal 2, res[:lvl2_slots]
      end

      def test_calculate_multiclass_no_casters
        levels = { fighter: 5, barbarian: 5 }
        res = SpellSlotCalculator.calculate_multiclass(levels)

        assert_empty res
      end

      def test_sum_levels
        levels = { wizard: 2, cleric: 3, fighter: 5 }

        assert_equal 5, SpellSlotCalculator.sum_levels(levels, %i[wizard cleric])
      end

      def test_calculate_unknown_class
        assert_empty SpellSlotCalculator.calculate('Unknown', 1)
      end
    end
  end
end
