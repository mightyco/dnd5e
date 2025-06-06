require_relative "../../test_helper"
require_relative "../../../lib/dnd5e/core/turn_manager"
require_relative "../../../lib/dnd5e/builders/character_builder"

module Dnd5e
  module Core
    class TestTurnManager < Minitest::Test
      def setup
        @statblock1 = Statblock.new(name: "Statblock 1", strength: 10, dexterity: 14, constitution: 12, hit_die: "d8", level: 1)
        @statblock2 = Statblock.new(name: "Statblock 2", strength: 12, dexterity: 16, constitution: 10, hit_die: "d6", level: 1)
        @combatant1 = Builders::CharacterBuilder.new(name: "Combatant 1")
                                                .with_statblock(@statblock1)
                                                .build
        @combatant2 = Builders::CharacterBuilder.new(name: "Combatant 2")
                                                .with_statblock(@statblock2)
                                                .build
        @combatants = [@combatant1, @combatant2]

        @logger = Logger.new($stdout)
        @logger.level = Logger::DEBUG
      end

      def test_initialization
        turn_manager = TurnManager.new(combatants: @combatants)
        assert_equal @combatants, turn_manager.combatants
        assert_empty turn_manager.turn_order
      end

      def test_roll_initiative
        mock_dice_roller = MockDiceRoller.new([10, 15])
        turn_manager = TurnManager.new(combatants: @combatants, dice_roller: mock_dice_roller)
        turn_manager.roll_initiative
        turn_manager.sort_by_initiative
        assert_equal 2, turn_manager.turn_order.size
        assert_equal 10 + @combatant1.statblock.ability_modifier(:dexterity), @combatant1.instance_variable_get(:@initiative)
        assert_equal 15 + @combatant2.statblock.ability_modifier(:dexterity), @combatant2.instance_variable_get(:@initiative)
      end

      def test_sort_by_initiative
        mock_dice_roller = MockDiceRoller.new([15, 10])
        turn_manager = TurnManager.new(combatants: @combatants, dice_roller: mock_dice_roller)
        turn_manager.roll_initiative
        turn_manager.sort_by_initiative
        assert_equal [@combatant1, @combatant2], turn_manager.turn_order
      end

      def test_sort_by_initiative_with_tie
        mock_dice_roller = MockDiceRoller.new([10, 10])
        turn_manager = TurnManager.new(combatants: @combatants, dice_roller: mock_dice_roller)
        turn_manager.roll_initiative
        turn_manager.sort_by_initiative
        assert_equal [@combatant2, @combatant1], turn_manager.turn_order
      end

      def test_next_turn
        turn_manager = TurnManager.new(combatants: @combatants)
        turn_manager.roll_initiative
        turn_manager.sort_by_initiative
        first_combatant = turn_manager.turn_order.first
        last_combatant = turn_manager.turn_order.last
        assert_equal last_combatant, turn_manager.next_turn
      end

      def test_next_turn_cycles
        turn_manager = TurnManager.new(combatants: @combatants)
        turn_manager.roll_initiative
        turn_manager.sort_by_initiative
        first_combatant = turn_manager.turn_order.first
        second_combatant = turn_manager.turn_order.last
        assert_equal second_combatant, turn_manager.next_turn
        assert_equal first_combatant, turn_manager.next_turn
        assert_equal second_combatant, turn_manager.next_turn
      end

      def test_all_turns_complete
        turn_manager = TurnManager.new(combatants: @combatants)
        turn_manager.roll_initiative
        turn_manager.sort_by_initiative
        turn_manager.next_turn
        refute turn_manager.all_turns_complete?
        turn_manager.next_turn
        assert turn_manager.all_turns_complete?
      end

      def test_next_turn_with_no_combatants
        turn_manager = TurnManager.new(combatants: [])
        assert_raises(TurnManager::NoCombatantsError) do
          turn_manager.next_turn
        end
      end

      def test_add_combatant
        turn_manager = TurnManager.new(combatants: @combatants)
        new_statblock = Statblock.new(name: "New Statblock", strength: 10, dexterity: 10, constitution: 10, hit_die: "d6", level: 1)
        new_combatant = Builders::CharacterBuilder.new(name: "New Combatant")
                                                  .with_statblock(new_statblock)
                                                  .build
        turn_manager.add_combatant(new_combatant)
        assert_includes turn_manager.combatants, new_combatant
      end

      def test_remove_combatant
        turn_manager = TurnManager.new(combatants: @combatants)
        turn_manager.remove_combatant(@combatant1)
        refute_includes turn_manager.combatants, @combatant1
        assert_equal [@combatant2], turn_manager.combatants
      end
    end
  end
end
