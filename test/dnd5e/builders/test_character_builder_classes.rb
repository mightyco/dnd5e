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

      def test_as_fighter_with_light_armor
        character = CharacterBuilder.new(name: 'Light Fighter')
                                    .as_fighter(level: 1, armor_type: :light)
                                    .build

        assert_equal 12, character.statblock.armor_class
      end

      def test_as_fighter_high_level_resources
        # Level 10 should have 4 second wind
        f10 = CharacterBuilder.new(name: 'F10').as_fighter(level: 10).build

        assert_equal 4, f10.statblock.resources.resources[:second_wind]
      end

      def test_as_fighter_action_surge_scaling
        # Level 17 should have 2 action surge
        f17 = CharacterBuilder.new(name: 'F17').as_fighter(level: 17).build

        assert_equal 2, f17.statblock.resources.resources[:action_surge]
      end

      def test_as_wizard
        character = CharacterBuilder.new(name: 'Wizard')
                                    .as_wizard(level: 1, abilities: { intelligence: 16, constitution: 14,
                                                                      dexterity: 12 })
                                    .build

        assert_equal 'Wizard', character.name
        assert_equal 16, character.statblock.intelligence
      end

      def test_as_barbarian
        character = CharacterBuilder.new(name: 'Barbarian').as_barbarian(level: 1).build

        assert_equal 'Barbarian', character.name
      end

      def test_as_barbarian_high_level_rage
        b6 = CharacterBuilder.new(name: 'B6').as_barbarian(level: 6).build

        assert_equal 4, b6.statblock.resources.resources[:rage]
      end

      def test_as_barbarian_rage_scaling
        b12 = CharacterBuilder.new(name: 'B12').as_barbarian(level: 12).build

        assert_equal 5, b12.statblock.resources.resources[:rage]

        b17 = CharacterBuilder.new(name: 'B17').as_barbarian(level: 17).build

        assert_equal 6, b17.statblock.resources.resources[:rage]
      end

      def test_as_paladin
        character = CharacterBuilder.new(name: 'Paladin').as_paladin(level: 1).build

        assert_equal 'Paladin', character.name
      end

      def test_as_paladin_level_two
        p2 = CharacterBuilder.new(name: 'P2').as_paladin(level: 2).build

        assert(p2.feature_manager.features.any? { |f| f.is_a?(Core::Features::DivineSmite) })
      end

      def test_as_monk
        character = CharacterBuilder.new(name: 'Monk').as_monk(level: 1).build

        assert_equal 'Monk', character.name
      end

      def test_as_monk_level_two
        m2 = CharacterBuilder.new(name: 'M2').as_monk(level: 2).build

        assert_equal 2, m2.statblock.resources.resources[:focus_points]
        assert(m2.feature_manager.features.any? { |f| f.is_a?(Core::Features::FlurryOfBlows) })
      end

      def test_as_ranger
        character = CharacterBuilder.new(name: 'Ranger').as_ranger(level: 1).build

        assert_equal 'Ranger', character.name
      end

      def test_as_ranger_equipment
        character = CharacterBuilder.new(name: 'Ranger').as_ranger(level: 1).build

        assert_equal 'Longbow', character.attacks.first.name
        assert_equal 150, character.attacks.first.range
      end

      def test_as_bard
        character = CharacterBuilder.new(name: 'Bard').as_bard(level: 1).build

        assert_equal 'Bard', character.name
      end

      def test_as_druid
        character = CharacterBuilder.new(name: 'Druid').as_druid(level: 1).build

        assert_equal 'Druid', character.name
      end

      def test_as_sorcerer
        character = CharacterBuilder.new(name: 'Sorcerer').as_sorcerer(level: 1).build

        assert_equal 'Sorcerer', character.name
      end

      def test_as_warlock
        character = CharacterBuilder.new(name: 'Warlock').as_warlock(level: 1).build

        assert_equal 'Warlock', character.name
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
