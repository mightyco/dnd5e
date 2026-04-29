# frozen_string_literal: true

require_relative '../../../test_helper'
require_relative '../../../../lib/dnd5e/core/subclass_registry'

module Dnd5e
  module Core
    module Features
      # Tests for remaining subclass features and edge cases.
      class TestSubclassFeatures < Minitest::Test
        def setup
          @char = Character.new(name: 'Hero', statblock: Statblock.new(name: 'Hero'))
        end

        def test_wild_heart_resistance
          feature = WildHeartFeatures.new
          @char.add_condition(:raging)
          context = { defender: @char, current_value: 10 }

          assert_equal 5, feature.on_damage_taken(context)
        end

        def test_zealot_divine_fury
          feature = DivineFury.new(level: 4)
          @char.add_condition(:raging)
          dice = Dice.new(1, 8, modifier: 3)
          context = { attacker: @char, dice: dice }

          new_dice = feature.on_damage_calculation(context)

          assert_equal 8, new_dice.modifier
        end

        def test_cutting_words
          feature = CuttingWords.new
          target = Character.new(name: 'Lore Bard', statblock: Statblock.new(name: 'Lore Bard'))
          roll_data = { total: 20 }
          context = { defender: target }

          new_roll = feature.on_after_attack_roll(context, roll_data)

          assert_equal 16, new_roll[:total]
        end

        def test_invoke_duplicity
          feature = InvokeDuplicity.new
          @char.add_condition(:duplicity_active)

          assert_equal 2, feature.on_attack_roll({ attacker: @char })
        end

        def test_vow_of_enmity
          feature = VowOfEnmity.new
          roll_data = { advantage: false }
          context = { options: { vow_target: true } }

          assert feature.on_after_attack_roll(context, roll_data)[:advantage]
        end

        def test_arcane_trickster_slots
          char = Builders::CharacterBuilder.new(name: 'Sly')
                                           .as_rogue(level: 3)
                                           .with_subclass(:arcane_trickster)
                                           .build

          assert_equal 2, char.statblock.resources.resources[:lvl1_slots]
        end
      end
    end
  end
end
