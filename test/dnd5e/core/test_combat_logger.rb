# frozen_string_literal: true

require_relative '../../test_helper'
require_relative '../../../lib/dnd5e/core/combat_logger'

module Dnd5e
  module Core
    class TestCombatLogger < Minitest::Test
      MockCombatant = Struct.new(:name)

      class MockLogger
        attr_reader :logs

        def initialize
          @logs = []
        end

        def info(msg)
          @logs << "INFO: #{msg}"
        end

        def debug(msg)
          @logs << "DEBUG: #{msg}"
        end
      end

      def setup
        @logger = MockLogger.new
        @combat_logger = CombatLogger.new(@logger)

        @hero = MockCombatant.new('Hero')
        @goblin = MockCombatant.new('Goblin')
      end

      def test_combat_start
        combatants = [@hero, @goblin]
        @combat_logger.update(:combat_start, combatants: combatants)

        assert_includes @logger.logs, 'INFO: Combat begins between Hero, Goblin'
      end

      def test_round_start
        @combat_logger.update(:round_start, round: 1)
        assert_includes @logger.logs, 'DEBUG: Round: 1'
      end

      def test_combat_end
        # Test with Mock for Winner
        winner = MockCombatant.new('Hero')
        initiative_winner = MockCombatant.new('Goblin')

        # Depending on if it's TeamCombat or regular Combat, winner might be Team or Combatant.
        # But both respond to :name.

        @combat_logger.update(:combat_end, winner: winner, initiative_winner: initiative_winner)

        assert_includes @logger.logs, 'INFO: Combat Over'
        assert_includes @logger.logs, 'INFO: Winner: Hero'
        assert_includes @logger.logs, 'INFO: Initiative Winner: Goblin'
      end
    end
  end
end
