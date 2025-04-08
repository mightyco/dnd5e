require_relative "../../test_helper"
require_relative "../../../lib/dnd5e/builders/character_builder"
require_relative "../../../lib/dnd5e/core/character"
require_relative "../../../lib/dnd5e/core/statblock"
require_relative "../../../lib/dnd5e/core/attack"

module Dnd5e
  module Builders
    class TestCharacterBuilder < Minitest::Test
      def setup
        @statblock = Core::Statblock.new(name: "Test Statblock")
        @attack = Core::Attack.new(name: "Test Attack", damage_dice: Core::Dice.new(1, 6))
      end

      def test_build_valid_character
        character = CharacterBuilder.new(name: "Test Character")
                                    .with_statblock(@statblock)
                                    .with_attack(@attack)
                                    .build

        assert_instance_of Core::Character, character
        assert_equal "Test Character", character.name
        assert_equal @statblock, character.statblock
        assert_includes character.attacks, @attack
      end

      def test_build_missing_name
        assert_raises CharacterBuilder::InvalidCharacterError do
          CharacterBuilder.new(name: nil).with_statblock(@statblock).build
        end
      end

      def test_build_missing_statblock
        assert_raises CharacterBuilder::InvalidCharacterError do
          CharacterBuilder.new(name: "Test Character").build
        end
      end
    end
  end
end
