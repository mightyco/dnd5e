# frozen_string_literal: true

require_relative '../../test_helper'
require_relative '../../../lib/dnd5e/builders/character_builder'

module Dnd5e
  module Core
    class TestMagicItems < Minitest::Test
      def setup
        @builder = Builders::CharacterBuilder.new(name: 'Arthur')
      end

      def test_plus_one_longsword
        hero = @builder.as_fighter(level: 1, abilities: { strength: 16 })
                       .with_magic_weapon('Longsword', 1)
                       .build

        attack = hero.attacks.find { |a| a.name == 'Longsword' }

        assert_equal 1, attack.magic_bonus

        # Attack mod: Str (3) + PB (2) + Magic (1) = 6
        mod = Helpers::AttackRollHelper.calculate_modifier(hero, nil, attack, {})

        assert_equal 6, mod

        # Damage mod: Str (3) + Magic (1) = 4
        dmg_mod = Helpers::DamageRollHelper.calculate_modifier(hero, attack, {})

        assert_equal 4, dmg_mod
      end

      def test_plus_one_plate
        hero = @builder.as_fighter(level: 1, armor_type: :heavy)
                       .with_magic_armor(1)
                       .build

        assert_equal 1, hero.statblock.equipped_armor.magic_bonus
        # Plate (16) + Magic (1) = 17
        assert_equal 17, hero.statblock.armor_class
      end
    end
  end
end
