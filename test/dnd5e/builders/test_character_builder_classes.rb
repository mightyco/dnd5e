# frozen_string_literal: true

require_relative '../../test_helper'
require_relative '../../../lib/dnd5e/builders/character_builder'

module Dnd5e
  module Builders
    class TestCharacterBuilderClasses < Minitest::Test
      def test_as_fighter
        character = CharacterBuilder.new(name: 'Fighter')
                                    .as_fighter(level: 1, abilities: { strength: 16, dexterity: 12, constitution: 14 })
                                    .build

        assert_equal 'Fighter', character.name
        assert_equal 16, character.statblock.strength
      end

      def test_as_fighter_with_medium_armor
        character = CharacterBuilder.new(name: 'Medium Fighter')
                                    .as_fighter(level: 1, armor_type: :medium)
                                    .build

        assert_equal 14, character.statblock.armor_class
      end

      def test_as_wizard
        character = CharacterBuilder.new(name: 'Wizard')
                                    .as_wizard(level: 1, abilities: { intelligence: 16, constitution: 14,
                                                                      dexterity: 12 })
                                    .build

        assert_equal 'Wizard', character.name
        assert_equal 16, character.statblock.intelligence
      end

      def test_class_levels_override
        character = CharacterBuilder.new(name: 'Cleric')
                                    .as_cleric(level: 3)
                                    .build

        assert_equal({ cleric: 3 }, character.statblock.class_levels)
        refute character.statblock.class_levels.key?(:character)
      end
    end
  end
end
