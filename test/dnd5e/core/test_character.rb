# frozen_string_literal: true

require_relative '../../test_helper'
require_relative '../../../lib/dnd5e/core/character'
require_relative '../../../lib/dnd5e/core/statblock'

module Dnd5e
  module Core
    class TestCharacter < Minitest::Test
      def test_initialize
        statblock = Statblock.new(name: 'TestStatblock', strength: 10, dexterity: 12, constitution: 14,
                                  intelligence: 8, wisdom: 16, charisma: 18, hit_die: 'd8')
        character = Character.new(name: 'TestCharacter', statblock: statblock)
        assert_equal 'TestCharacter', character.name
        assert_equal statblock, character.statblock
      end

      def test_character_uses_statblock_methods
        statblock = Statblock.new(name: 'TestStatblock', strength: 10, dexterity: 12, constitution: 14,
                                  intelligence: 8, wisdom: 16, charisma: 18, hit_die: 'd8')
        character = Character.new(name: 'TestCharacter', statblock: statblock)
        character.statblock.take_damage(5)
        assert_equal 5, character.statblock.hit_points
        character.statblock.heal(2)
        assert_equal 7, character.statblock.hit_points
        character.statblock.level_up
        assert_equal 2, character.statblock.level
      end
    end
  end
end
