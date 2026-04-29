# frozen_string_literal: true

require_relative '../../../test_helper'
require_relative '../../../../lib/dnd5e/core/subclass_registry'

module Dnd5e
  module Core
    module Features
      class TestMartialFeatures < Minitest::Test
        def setup
          @char = Character.new(name: 'Hero', statblock: Statblock.new(name: 'Hero'))
        end

        def test_thief_init
          feature = ThiefFeatures.new
          @char.feature_manager.add_feature(feature)
          initial_speed = @char.statblock.speed
          @char.feature_manager.on_character_init(@char)

          assert_equal initial_speed + 10, @char.statblock.speed
        end

        def test_shadow_arts
          assert ShadowArts.new
        end

        def test_war_bond
          feature = WarBond.new
          atk = Attack.new(name: 'Sword', damage_dice: Dice.new(1, 8))
          @char.attacks << atk
          feature.on_character_init({ character: @char })

          assert_equal 1, atk.instance_variable_get(:@magic_bonus)
        end

        def test_elemental_reach
          feature = ElementalReach.new
          feature.on_character_init({ character: @char })

          assert_equal 'Elemental Reach', feature.name
        end
      end
    end
  end
end
