# frozen_string_literal: true

require_relative 'test_helper'

module Dnd5e
  class MulticlassTest < Minitest::Test
    def test_fighter_wizard_multiclass_foundation
      builder = Builders::CharacterBuilder.new(name: 'Gandalf the Swashbuckler')
      builder.as_fighter(level: 1, abilities: { strength: 14, intelligence: 14 })
             .as_wizard(level: 1)

      character = builder.build

      assert_equal 2, character.statblock.level
      assert_equal 1, character.statblock.class_levels[:fighter]
      assert_equal 1, character.statblock.class_levels[:wizard]
    end

    def test_fighter_wizard_multiclass_slots
      builder = Builders::CharacterBuilder.new(name: 'Gandalf')
      builder.as_fighter(level: 1, abilities: { constitution: 10 })
             .as_wizard(level: 1)
      character = builder.build

      # Resources: Level 1 Wizard slots (since Fighter is 0)
      assert_equal 2, character.statblock.resources.resources[:lvl1_slots]
    end

    def test_fighter_wizard_multiclass_hp
      builder = Builders::CharacterBuilder.new(name: 'Gandalf')
      builder.as_fighter(level: 1, abilities: { constitution: 10 })
             .as_wizard(level: 1)
      character = builder.build

      assert_equal 14, character.statblock.max_hp
    end

    def test_sorcerer_monk_resources
      builder = Builders::CharacterBuilder.new(name: 'Sorcomonk')
      char = builder.as_sorcerer(level: 2)
                    .as_monk(level: 2)
                    .build

      assert_equal 2, char.statblock.resources.resources[:sorcery_points]
      assert_equal 2, char.statblock.resources.resources[:focus_points]
    end
  end
end
