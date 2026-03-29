# frozen_string_literal: true

require_relative '../../test_helper'
require_relative '../../../lib/dnd5e/core/combat_logger'

module Dnd5e
  module Core
    class TestCombatLogger < Minitest::Test
      MockCombatant = Struct.new(:name)
      MockAttack = Struct.new(:name, :save_ability)
      MockResult = Struct.new(:attacker, :defender, :attack, :success, :damage, :type, :attack_roll,
                              :target_ac, :raw_roll, :modifier, :rolls, :damage_rolls, :damage_modifier,
                              :save_roll, :save_dc, :is_dead, :advantage, :disadvantage,
                              :current_hp, :max_hp, :proficiency_bonus)

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

        def warn(msg)
          @logs << "WARN: #{msg}"
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
        winner = MockCombatant.new('Hero')
        initiative_winner = MockCombatant.new('Goblin')

        @combat_logger.update(:combat_end, winner: winner, initiative_winner: initiative_winner)

        assert_includes @logger.logs, 'INFO: Combat Over'
        assert_includes @logger.logs, 'INFO: Winner: Hero'
        assert_includes @logger.logs, 'INFO: Initiative Winner: Goblin'
      end

      def test_attack_hit_logging
        result = MockResult.new(@hero, @goblin, MockAttack.new('Sword'), true, 10, :attack, 15, 10,
                                10, 5, [10], [7], 3, nil, nil, false, false, false, 5, 15, 2)
        @combat_logger.update(:attack_resolved, result: result)

        assert_includes @logger.logs, 'INFO: Hero hits Goblin with Sword for 10 damage! (7 + 3) | Goblin HP: 5/15'
      end

      def test_attack_miss_logging
        result = MockResult.new(@hero, @goblin, MockAttack.new('Sword'), false, 0, :attack, 8, 10,
                                3, 5, [3], [], 0, nil, nil, false, false, false, 15, 15, 2)
        @combat_logger.update(:attack_resolved, result: result)

        assert_includes @logger.logs, 'INFO: Hero misses Goblin with Sword!'
      end

      def test_save_logging
        result = MockResult.new(@hero, @goblin, MockAttack.new('Fireball', :dexterity), true, 20, :save, nil, nil,
                                10, 0, [10], [20], 0, 10, 15, false, false, false, 10, 30, 2)
        @combat_logger.update(:attack_resolved, result: result)

        assert_includes @logger.logs, 'INFO: Goblin fails dexterity save against Fireball!'
        assert_includes @logger.logs, 'INFO: Goblin takes 20 damage! (20 + 0)'
      end

      def test_defeat_logging
        result = MockResult.new(@hero, @goblin, MockAttack.new('Sword'), true, 10, :attack, 15, 10,
                                10, 5, [10], [10], 0, nil, nil, true, false, false, 0, 15, 2)
        @combat_logger.update(:attack_resolved, result: result)

        assert_includes @logger.logs, 'INFO: [DEFEATED] Goblin has been defeated!'
      end

      def test_advantage_logging
        result = MockResult.new(@hero, @goblin, MockAttack.new('Sword'), true, 10, :attack, 20, 10,
                                15, 5, [10, 15], [10], 0, nil, nil, false, true, false, 5, 15, 2)
        @combat_logger.update(:attack_resolved, result: result)

        assert_includes @logger.logs.join, '(Adv: [15, 10] -> 15 +3 Mod +2 Prof)'
      end
    end
  end
end
