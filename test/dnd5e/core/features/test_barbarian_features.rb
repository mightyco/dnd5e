# frozen_string_literal: true

require_relative '../../../test_helper'
require_relative '../../../../lib/dnd5e/core/features/barbarian_features'
require_relative '../../../../lib/dnd5e/core/features/barbarian_berserker'
require_relative '../../../../lib/dnd5e/core/character'
require_relative '../../../../lib/dnd5e/builders/character_builder'

module Dnd5e
  module Core
    module Features
      class TestBarbarianFeatures < Minitest::Test
        def setup
          @builder = Builders::CharacterBuilder.new(name: 'Grog')
          @barbarian = @builder.as_barbarian(level: 3, abilities: { strength: 16 }).build
          @rage = @barbarian.feature_manager.features.find { |f| f.is_a?(Rage) }
        end

        def test_rage_damage_bonus
          @barbarian.add_condition(:raging)
          attack = Attack.new(name: 'Greataxe', damage_dice: Dice.new(1, 12, modifier: 3), relevant_stat: :strength)

          context = { attacker: @barbarian, attack: attack, dice: attack.damage_dice }
          modified_dice = @rage.on_damage_calculation(context)

          # Base 3 + Rage 2 = 5
          assert_equal 5, modified_dice.modifier
        end

        def test_rage_resistance
          @barbarian.add_condition(:raging)

          context = { defender: @barbarian, damage: 10, damage_type: :slashing }
          reduced_damage = @rage.on_damage_taken(context)

          assert_equal 5, reduced_damage
        end

        def test_frenzy_damage
          frenzy = Frenzy.new
          @barbarian.feature_manager.features << frenzy
          @barbarian.add_condition(:raging)

          attack = Attack.new(name: 'Greataxe', damage_dice: Dice.new(1, 12, modifier: 3), relevant_stat: :strength)
          # Frenzy requires reckless option
          context = { attacker: @barbarian, attack: attack, dice: attack.damage_dice, options: { reckless: true } }

          modified_dice = frenzy.on_damage_calculation(context)

          # Base 1d12 + Frenzy 2d6 (since rage bonus is 2)
          assert_equal 3, modified_dice.count
          assert_equal 6, modified_dice.sides # Frenzy uses d6s
        end
      end
    end
  end
end
