# frozen_string_literal: true

require_relative '../../test_helper'
require_relative '../../../lib/dnd5e/builders/character_builder'
require_relative '../../../lib/dnd5e/core/statblock'
require_relative '../../../lib/dnd5e/core/attack'
require_relative '../../../lib/dnd5e/core/dice'

module Dnd5e
  module Builders
    class TestCharacterBuilder < Minitest::Test
      def test_builder
        builder = CharacterBuilder.new(name: 'Aragorn')
        builder.with_statblock(Core::Statblock.new(name: 'Aragorn', strength: 18))
        builder.with_attack(Core::Attack.new(name: 'Sword', damage_dice: Core::Dice.new(1, 8)))
        character = builder.build

        assert_basic_character(character, 'Aragorn', 18)
        assert_equal 1, character.attacks.length
        assert_equal 'Sword', character.attacks.first.name
      end

      def test_as_fighter
        character = CharacterBuilder.new(name: 'Fighter')
                                    .as_fighter(level: 1, abilities: { strength: 16, dexterity: 12, constitution: 14 })
                                    .build

        verify_fighter_stats(character)
      end

      def test_as_wizard
        character = CharacterBuilder.new(name: 'Wizard')
                                    .as_wizard(level: 1, abilities: { intelligence: 16, constitution: 14,
                                                                      dexterity: 12 })
                                    .build

        verify_wizard_stats(character)
      end

      private

      def assert_basic_character(character, name, strength)
        assert_equal name, character.name
        assert_equal strength, character.statblock.strength
      end

      def verify_fighter_stats(character)
        assert_equal 'Fighter', character.name
        verify_fighter_statblock(character.statblock)

        assert_equal 'Longsword', character.attacks.first.name
      end

      def verify_fighter_statblock(statblock)
        assert_equal 16, statblock.strength
        assert_equal 14, statblock.constitution
        assert_equal 'd10', statblock.hit_die
        assert_includes statblock.saving_throw_proficiencies, :strength
      end

      def verify_wizard_stats(character)
        assert_equal 'Wizard', character.name
        assert_equal 16, character.statblock.intelligence
        assert_equal 'd6', character.statblock.hit_die
        assert_includes character.statblock.saving_throw_proficiencies, :intelligence
        assert_equal 'Firebolt', character.attacks.first.name
      end
    end
  end
end
