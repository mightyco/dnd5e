require_relative "../../test_helper"
require_relative "../../../lib/dnd5e/core/turn_manager"
require_relative "../../../lib/dnd5e/core/character"
require_relative "../../../lib/dnd5e/core/statblock"
require_relative "../../../lib/dnd5e/core/dice"
require_relative "../../../lib/dnd5e/core/dice_roller"

module Dnd5e
  module Core
    class TestTurnManager < Minitest::Test
      def setup
        @statblock1 = Statblock.new(name: "Statblock 1", strength: 10, dexterity: 14, constitution: 12, hit_die: "d8", level: 1)
        @statblock2 = Statblock.new(name: "Statblock 2", strength: 12, dexterity: 16, constitution: 10, hit_die: "d6", level: 1)
        @combatant1 = Character.new(name: "Combatant 1", statblock: @statblock1.deep_copy, attacks: [])
        @combatant2 = Character.new(name: "Combatant 2", statblock: @statblock2.deep_copy, attacks: [])
        @combatants = [@combatant1, @combatant2]
        @turn_manager = TurnManager.new(combatants: @combatants)
      end

      def test_initialization
        assert_equal @combatants, @turn_manager.combatants
        assert_empty @turn_manager.turn_order
      end

      def test_roll_initiative
        @turn_manager.roll_initiative
        assert_equal 2, @turn_manager.turn_order.size
        @turn_manager.turn_order.each do |combatant|
          assert combatant.instance_variable_get(:@initiative).is_a?(Integer)
          assert combatant.instance_variable_get(:@initiative) >= 1
          assert combatant.instance_variable_get(:@initiative) <= 20 + combatant.statblock.ability_modifier(:dexterity)
        end
      end

      def test_sort_by_initiative
        mock_dice_roller = MockDiceRoller.new([15, 10])
        @turn_manager.instance_variable_set(:@dice_roller, mock_dice_roller)
        @turn_manager.roll_initiative
        @turn_manager.sort_by_initiative
        assert_equal [@combatant1, @combatant2], @turn_manager.turn_order
      end

      def test_sort_by_initiative_with_tie
        mock_dice_roller = MockDiceRoller.new([10, 10])
        @turn_manager.instance_variable_set(:@dice_roller, mock_dice_roller)
        @turn_manager.roll_initiative
        @turn_manager.sort_by_initiative
        assert_equal [@combatant2, @combatant1], @turn_manager.turn_order
      end

      def test_next_turn
        @turn_manager.roll_initiative
        @turn_manager.sort_by_initiative
        first_combatant = @turn_manager.turn_order.first
        assert_equal first_combatant, @turn_manager.next_turn
      end

      def test_next_turn_cycles
        @turn_manager.roll_initiative
        @turn_manager.sort_by_initiative
        first_combatant = @turn_manager.turn_order.first
        second_combatant = @turn_manager.turn_order.last
        assert_equal first_combatant, @turn_manager.next_turn
        assert_equal second_combatant, @turn_manager.next_turn
        assert_equal first_combatant, @turn_manager.next_turn
      end

      def test_all_turns_complete
        @turn_manager.roll_initiative
        @turn_manager.sort_by_initiative
        @turn_manager.next_turn
        refute @turn_manager.all_turns_complete?
        @turn_manager.next_turn
        assert @turn_manager.all_turns_complete?
      end

      def test_next_turn_with_no_combatants
        turn_manager = TurnManager.new(combatants: [])
        assert_raises(TurnManager::NoCombatantsError) do
          turn_manager.next_turn
        end
      end

      def test_add_combatant
        new_statblock = Statblock.new(name: "New Statblock", strength: 10, dexterity: 10, constitution: 10, hit_die: "d6", level: 1)
        new_combatant = Character.new(name: "New Combatant", statblock: new_statblock, attacks: [])
        @turn_manager.add_combatant(new_combatant)
        assert_includes @turn_manager.combatants, new_combatant
      end

      def test_remove_combatant
        @turn_manager.remove_combatant(@combatant1)
        refute_includes @turn_manager.combatants, @combatant1
      end
    end
  end
end
