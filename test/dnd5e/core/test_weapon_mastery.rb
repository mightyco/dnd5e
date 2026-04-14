# frozen_string_literal: true

require_relative '../../test_helper'
require_relative '../../../lib/dnd5e/core/attack_resolver'
require_relative '../../../lib/dnd5e/core/attack'
require_relative '../../../lib/dnd5e/core/statblock'
require_relative '../../../lib/dnd5e/core/character'

module Dnd5e
  module Core
    class TestWeaponMastery < Minitest::Test
      def setup
        @attacker_stat = Statblock.new(name: 'Attacker', strength: 16)
        @attacker = Character.new(name: 'Attacker', statblock: @attacker_stat)

        @defender_stat = Statblock.new(name: 'Defender', armor_class: 10, dexterity: 10)
        @defender = Character.new(name: 'Defender', statblock: @defender_stat)

        @resolver = AttackResolver.new
      end

      def test_vex_mastery_applies_condition
        vex_sword = Attack.new(name: 'Vex Sword', damage_dice: Dice.new(1, 8), mastery: :vex)
        # Force a hit (Roll 10 + 3 mod = 13 vs AC 10)
        mock_roller = MockDiceRoller.new([10, 5])
        vex_sword.instance_variable_set(:@dice_roller, mock_roller)

        @resolver.resolve(@attacker, @defender, vex_sword)

        assert @attacker.statblock.condition?(:vexing)
        context = @attacker.statblock.condition_manager.get_context(:vexing)

        assert_equal @defender, context[:target]
      end

      def test_vex_mastery_provides_advantage
        @attacker.statblock.add_condition(:vexing, { target: @defender })

        # Next attack should use roll_with_advantage
        mock_roller = MockDiceRoller.new([10, 15, 5]) # Two initiative/attack rolls, one damage
        sword = Attack.new(name: 'Sword', damage_dice: Dice.new(1, 8), dice_roller: mock_roller)

        @resolver.resolve(@attacker, @defender, sword)

        assert_includes mock_roller.calls, :roll_with_advantage
      end

      def test_topple_mastery_knocks_prone
        topple_axe = Attack.new(name: 'Topple Axe', damage_dice: Dice.new(1, 10), mastery: :topple)
        # 1. Attack Roll: 10
        # 2. Damage Roll: 5
        # 3. Topple Save: 5 (FAIL vs DC 13)
        # + extra safety rolls for potential hook interference
        mock_roller = MockDiceRoller.new([10, 5, 5, 5, 5])
        topple_axe.instance_variable_set(:@dice_roller, mock_roller)

        @resolver.resolve(@attacker, @defender, topple_axe)

        assert_predicate @defender.statblock, :prone?
      end

      def test_topple_mastery_save_success
        topple_axe = Attack.new(name: 'Topple Axe', damage_dice: Dice.new(1, 10), mastery: :topple)
        # 1. Attack Roll: 10
        # 2. Damage Roll: 5
        # 3. Topple Save: 15 (SUCCESS vs DC 13)
        mock_roller = MockDiceRoller.new([10, 5, 15, 5, 5])
        topple_axe.instance_variable_set(:@dice_roller, mock_roller)

        @resolver.resolve(@attacker, @defender, topple_axe)

        refute_predicate @defender.statblock, :prone?, 'Defender should not be prone on successful save'
      end
    end
  end
end
