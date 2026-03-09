# frozen_string_literal: true

require_relative '../../test_helper'
require_relative '../../../lib/dnd5e/core/magic_item'

module Dnd5e
  module Core
    class TestMagicItem < Minitest::Test
      def test_initialization
        item = create_test_item

        assert_equal 'Vorpal Sword', item.name
        assert_equal 'Legendary', item.rarity
        assert_equal 'Weapon', item.type
        assert_predicate item, :attunement
        assert_equal 'Snicker-snack!', item.description
      end

      private

      def create_test_item
        MagicItem.new(
          name: 'Vorpal Sword',
          rarity: 'Legendary',
          type: 'Weapon',
          attunement: true,
          description: 'Snicker-snack!'
        )
      end
    end
  end
end
