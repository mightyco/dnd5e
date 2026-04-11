# frozen_string_literal: true

require_relative '../../../test_helper'
require_relative '../../../../lib/dnd5e/core/combat'

module Dnd5e
  module Core
    class ManualMockRoller
      def roll_with_advantage(_sides, modifier: 0) = modifier + 12
      def roll_with_disadvantage(_sides, modifier: 0) = modifier + 12

      def roll_with_dice(dice)
        dice.sides == 20 ? dice.modifier + 12 : dice.modifier + 4
      end

      def roll(_formula) = 4
      def dice = Struct.new(:rolls).new([12])
    end

    class BattleMasterResourceTest < Minitest::Test
      def setup
        @strat = Strategies::BattleMasterStrategy.new(use_precision_attack: true, use_damage_maneuver: true)
        @bm = Builders::CharacterBuilder.new(name: 'BM')
                                        .as_fighter(level: 3)
                                        .with_subclass(:battlemaster)
                                        .build
        @bm.strategy = @strat
        @goblin = Builders::MonsterBuilder.new(name: 'G').as_goblin.build
        @combat = Combat.new(combatants: [@bm, @goblin])
      end

      def test_does_not_consume_two_dice_on_precision_plus_damage_maneuver
        setup_controlled_attack
        initial_dice = @bm.statblock.resources.resources[:superiority_dice]

        @bm.start_turn
        @combat.take_turn(@bm)

        final_dice = @bm.statblock.resources.resources[:superiority_dice]

        assert_operator final_dice, :>=, initial_dice - 1, 'Should not consume more than 1 superiority die per attack'
      end

      private

      def setup_controlled_attack
        @goblin.statblock.armor_class = 15
        @bm.statblock.strength = 10 # +0
        mock_roller = ManualMockRoller.new
        @bm.attacks.first.instance_variable_set(:@dice_roller, mock_roller)
        bm_feat = @bm.feature_manager.features.find { |f| f.name == 'Battle Master' }
        bm_feat.instance_variable_set(:@dice_roller, mock_roller)
      end
    end
  end
end
