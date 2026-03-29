# frozen_string_literal: true

require_relative '../../../test_helper'
require_relative '../../../../lib/dnd5e/core/features/improved_critical'
require_relative '../../../../lib/dnd5e/core/character'
require_relative '../../../../lib/dnd5e/core/statblock'
require_relative '../../../../lib/dnd5e/core/attack_resolver'

module Dnd5e
  module Core
    module Features
      class TestImprovedCritical < Minitest::Test
        def setup
          @statblock = Statblock.new(name: 'Champion', strength: 16)
          @feature = ImprovedCritical.new
          @character = Character.new(name: 'Champion', statblock: @statblock, features: [@feature])
          @mock_dice_roller = MockDiceRoller.new([19, 10]) # Attack 19, Damage 10
          @attack = Attack.new(name: 'Maul', damage_dice: Dice.new(2, 6), relevant_stat: :strength,
                               dice_roller: @mock_dice_roller)
          @defender = Character.new(name: 'Target', statblock: Statblock.new(name: 'Target', armor_class: 15))
          @resolver = AttackResolver.new
        end

        def test_threshold_reduction
          assert_equal 19, @character.statblock.crit_threshold
        end

        def test_critical_at_nineteen
          result = @resolver.resolve(@character, @defender, @attack)

          assert result.success
          assert_equal 19 + 3 + 2, result.attack_roll

          # Damage should be doubled (4d6 instead of 2d6)
          last_dice = @mock_dice_roller.last_dice_params.last

          assert_equal 4, last_dice.count
        end
      end
    end
  end
end
