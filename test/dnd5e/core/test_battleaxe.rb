# frozen_string_literal: true

require_relative '../../test_helper'
require_relative '../../../lib/dnd5e/core/weapon_registry'
require_relative '../../../lib/dnd5e/core/attack_resolver'

module Dnd5e
  module Core
    class TestBattleaxe < Minitest::Test
      def setup
        @attacker_stat = Statblock.new(name: 'Attacker', strength: 16)
        @attacker = Character.new(name: 'Attacker', statblock: @attacker_stat)
        @defender_stat = Statblock.new(name: 'Defender', armor_class: 10, dexterity: 10)
        @defender = Character.new(name: 'Defender', statblock: @defender_stat)
        @resolver = AttackResolver.new
      end

      def test_battleaxe_exists_in_registry
        battleaxe = WeaponRegistry.create('battleaxe')

        assert_equal 'Battleaxe', battleaxe.name
        assert_equal '1d8', battleaxe.damage_dice.to_s
        assert_equal :topple, battleaxe.mastery
        assert_includes battleaxe.properties, :versatile
      end

      def test_battleaxe_topple_effect
        battleaxe = WeaponRegistry.create('battleaxe')
        # Roll 10 (Hit), 5 (Damage), 5 (Save Fail)
        mock = MockDiceRoller.new([10, 5, 5, 5])
        battleaxe.instance_variable_set(:@dice_roller, mock)

        @resolver.resolve(@attacker, @defender, battleaxe)

        assert_predicate @defender, :prone?, 'Defender should be prone after Topple hit'
      end
    end
  end
end
