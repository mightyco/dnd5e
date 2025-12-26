require_relative "../../test_helper"
require_relative "../../../lib/dnd5e/builders/character_builder"
require_relative "../../../lib/dnd5e/core/dice_roller"

module Dnd5e
  module Builders
    class TestCharacterBuilder < Minitest::Test
      def test_build_simple
        builder = CharacterBuilder.new(name: "Bob")
        statblock = Core::Statblock.new(name: "Bob")
        builder.with_statblock(statblock)
        character = builder.build
        
        assert_equal "Bob", character.name
        assert_equal statblock, character.statblock
      end
      
      def test_as_fighter
        builder = CharacterBuilder.new(name: "Fighter Bob")
        builder.as_fighter(level: 1, abilities: { strength: 16, constitution: 14 })
        character = builder.build
        
        assert_equal "d10", character.statblock.hit_die
        assert_equal 16, character.statblock.strength
        assert_equal 14, character.statblock.constitution
        assert_includes character.statblock.saving_throw_proficiencies, :strength
        assert_includes character.statblock.saving_throw_proficiencies, :constitution
        
        # Check Longsword
        assert character.attacks.any? { |a| a.name == "Longsword" }
      end
      
      def test_as_wizard
        builder = CharacterBuilder.new(name: "Wizard Gandalf")
        builder.as_wizard(level: 1, abilities: { intelligence: 18, wisdom: 12 })
        character = builder.build
        
        assert_equal "d6", character.statblock.hit_die
        assert_equal 18, character.statblock.intelligence
        assert_includes character.statblock.saving_throw_proficiencies, :intelligence
        assert_includes character.statblock.saving_throw_proficiencies, :wisdom
        
        # Check Staff and Firebolt
        assert character.attacks.any? { |a| a.name == "Quarterstaff" }
        assert character.attacks.any? { |a| a.name == "Firebolt" }
      end
    end
  end
end
