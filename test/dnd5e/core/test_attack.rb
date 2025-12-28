# frozen_string_literal: true

require_relative '../../test_helper'
require_relative '../../../lib/dnd5e/core/attack'
require_relative '../../../lib/dnd5e/core/dice'

module Dnd5e
  module Core
    class TestAttack < Minitest::Test
      def setup
        @damage_dice = Dice.new(1, 8)
      end

      def test_initialization
        attack = Attack.new(name: 'Sword', damage_dice: @damage_dice, relevant_stat: :strength)

        assert_equal 'Sword', attack.name
        assert_equal @damage_dice, attack.damage_dice
        assert_equal :strength, attack.relevant_stat
        assert_equal :attack, attack.type
      end

      def test_save_based_attack
        attack = create_save_attack

        assert_equal :save, attack.type
        assert_equal :dexterity, attack.save_ability
        assert_equal 15, attack.fixed_dc
        assert attack.half_damage_on_save
        assert_equal :intelligence, attack.dc_stat
      end

      private

      def create_save_attack
        Attack.new(
          name: 'Fireball',
          damage_dice: @damage_dice,
          type: :save,
          save_ability: :dexterity,
          fixed_dc: 15,
          half_damage_on_save: true,
          dc_stat: :intelligence
        )
      end
    end
  end
end
