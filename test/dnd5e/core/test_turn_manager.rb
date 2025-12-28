# frozen_string_literal: true

require_relative '../../test_helper'
require_relative '../../../lib/dnd5e/core/turn_manager'
require_relative '../../../lib/dnd5e/core/character'
require_relative '../../../lib/dnd5e/core/monster'
require_relative '../../../lib/dnd5e/core/dice_roller'
require_relative '../../../lib/dnd5e/builders/character_builder'
require_relative '../../../lib/dnd5e/builders/monster_builder'

module Dnd5e
  module Core
    class TestTurnManager < Minitest::Test
      def setup
        @hero1 = create_combatant('Hero 1', 14) # Dex 14 -> +2
        @hero2 = create_combatant('Hero 2', 10) # Dex 10 -> +0
        @goblin1 = create_combatant('Goblin 1', 12) # Dex 12 -> +1
        @goblin2 = create_combatant('Goblin 2', 8)  # Dex 8 -> -1

        @combatants = [@hero1, @hero2, @goblin1, @goblin2]
        @turn_manager = TurnManager.new(combatants: @combatants)
      end

      def create_combatant(name, dex)
        statblock = Statblock.new(name: 'Base', dexterity: dex)
        Character.new(name: name, statblock: statblock, attacks: [])
      end

      def test_roll_initiative
        # Mock dice roller to control initiative rolls
        # Combatants order in @combatants: Hero1 (+2), Hero2 (0), Goblin1 (+1), Goblin2 (-1)
        # We want final order: Hero1 (22), Goblin1 (16), Hero2 (10), Goblin2 (5)
        # Rolls needed: 20, 15, 10, 6 (base rolls before mod)

        mock_dice = MockDiceRoller.new([20, 10, 15, 6])
        @turn_manager.instance_variable_set(:@dice_roller, mock_dice)

        @turn_manager.roll_initiative

        # Verify initiative values
        assert_equal 22, @hero1.instance_variable_get(:@initiative)
        assert_equal 10, @hero2.instance_variable_get(:@initiative)
        assert_equal 16, @goblin1.instance_variable_get(:@initiative)
        assert_equal 5, @goblin2.instance_variable_get(:@initiative)

        @turn_manager.sort_by_initiative

        assert_equal [@hero1, @goblin1, @hero2, @goblin2], @turn_manager.turn_order
      end

      def test_next_turn
        # Set turn order manually for testing
        @turn_manager.instance_variable_set(:@turn_order, [@hero1, @goblin1])
        # Start at 0 to get first combatant
        @turn_manager.instance_variable_set(:@current_turn_index, 0)

        assert_equal @hero1, @turn_manager.next_turn
        assert_equal 1, @turn_manager.instance_variable_get(:@current_turn_index)

        assert_equal @goblin1, @turn_manager.next_turn
        assert_equal 0, @turn_manager.instance_variable_get(:@current_turn_index)

        # Should loop back to start
        assert_equal @hero1, @turn_manager.next_turn
      end
    end
  end
end
