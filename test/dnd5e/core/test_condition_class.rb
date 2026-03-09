# frozen_string_literal: true

require_relative '../../test_helper'
require_relative '../../../lib/dnd5e/core/condition'

module Dnd5e
  module Core
    class TestCondition < Minitest::Test
      def test_initialization
        condition = Condition.new(
          name: :blinded,
          description: 'Cannot see.',
          mechanics: { disadvantage_on_attacks: true }
        )

        assert_equal :blinded, condition.name
        assert_equal 'Cannot see.', condition.description
        assert condition.mechanics[:disadvantage_on_attacks]
      end

      def test_new_from_name
        condition = Condition.new_from_name(:prone)

        assert_equal :prone, condition.name
        assert_match(/prone creature/, condition.description)
        assert condition.mechanics[:disadvantage_on_attacks]
      end

      def test_new_from_name_invalid
        assert_raises(ArgumentError) { Condition.new_from_name(:nonexistent) }
      end
    end
  end
end
