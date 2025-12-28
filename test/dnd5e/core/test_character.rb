# frozen_string_literal: true

require_relative '../../test_helper'
require_relative '../../../lib/dnd5e/core/character'
require_relative '../../../lib/dnd5e/core/statblock'
require_relative '../../../lib/dnd5e/core/attack'
require_relative '../../../lib/dnd5e/core/dice'

module Dnd5e
  module Core
    class TestCharacter < Minitest::Test
      def setup
        @statblock = Statblock.new(name: 'Hero', strength: 16, dexterity: 12, constitution: 14,
                                   hit_die: 'd10', level: 1)
        @attack = Attack.new(name: 'Sword', damage_dice: Dice.new(1, 8), relevant_stat: :strength)
        @character = Character.new(name: 'Hero', statblock: @statblock, attacks: [@attack])
      end

      def test_initialization
        assert_equal 'Hero', @character.name
        assert_equal @statblock, @character.statblock
        assert_equal [@attack], @character.attacks
        assert_nil @character.team
      end

      def test_character_uses_statblock_methods
        verify_initial_stats
        verify_damage_taking
        verify_healing
      end

      private

      def verify_initial_stats
        assert_equal 16, @character.statblock.strength
        assert_equal 3, @character.statblock.ability_modifier(:strength)
        assert_equal 12, @character.statblock.hit_points
        assert_predicate @character.statblock, :alive?
      end

      def verify_damage_taking
        @character.statblock.take_damage(5)

        assert_equal 7, @character.statblock.hit_points
      end

      def verify_healing
        @character.statblock.heal(2)

        assert_equal 9, @character.statblock.hit_points
      end
    end
  end
end
