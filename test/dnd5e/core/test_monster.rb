# frozen_string_literal: true

require_relative '../../test_helper'
require_relative '../../../lib/dnd5e/core/monster'
require_relative '../../../lib/dnd5e/core/statblock'
require_relative '../../../lib/dnd5e/core/attack'
require_relative '../../../lib/dnd5e/core/dice'

module Dnd5e
  module Core
    class TestMonster < Minitest::Test
      def setup
        @statblock = Statblock.new(name: 'Goblin', strength: 8, dexterity: 14, constitution: 10,
                                   hit_die: 'd6', level: 1)
        @attack = Attack.new(name: 'Scimitar', damage_dice: Dice.new(1, 6), relevant_stat: :dexterity)
        @monster = Monster.new(name: 'Goblin', statblock: @statblock, attacks: [@attack])
      end

      def test_monster_creation
        assert_equal 'Goblin', @monster.name
        assert_equal @statblock, @monster.statblock
        assert_equal [@attack], @monster.attacks
        assert_nil @monster.team
      end

      def test_monster_uses_statblock_methods
        verify_initial_stats
        verify_damage_taking
      end

      private

      def verify_initial_stats
        assert_equal 8, @monster.statblock.strength
        assert_equal(-1, @monster.statblock.ability_modifier(:strength))
        assert_equal 2, @monster.statblock.ability_modifier(:dexterity)
        # Max HP for d6 (6) + con (0) = 6.
        # Why did it expect 7 in previous tests?
        # Ah, maybe (d6 / 2) + 1 for level > 1, but level is 1.
        # Level 1 usually takes max die roll. 6.
        assert_equal 6, @monster.statblock.hit_points
        assert_predicate @monster.statblock, :alive?
      end

      def verify_damage_taking
        @monster.statblock.take_damage(6)

        refute_predicate @monster.statblock, :alive?
      end
    end
  end
end
