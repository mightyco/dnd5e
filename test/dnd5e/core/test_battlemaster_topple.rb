# frozen_string_literal: true

require_relative '../../test_helper'
require_relative '../../../lib/dnd5e/core/features/battle_master'
require_relative '../../../lib/dnd5e/core/strategies/battle_master_strategy'
require_relative '../../../lib/dnd5e/core/character'
require_relative '../../../lib/dnd5e/core/statblock'
require_relative '../../../lib/dnd5e/core/attack'
require_relative '../../../lib/dnd5e/core/team_combat'
require_relative '../../../lib/dnd5e/core/team'

module Dnd5e
  module Core
    class TestBattleMasterTopple < Minitest::Test
      def setup
        @bm = Features::BattleMaster.new(level: 3)
        @stat = Statblock.new(name: 'Hero', strength: 16)
        @hero = Character.new(name: 'Hero', statblock: @stat, features: [@bm], strategy: Strategies::BattleMasterStrategy.new)

        @target_stat = Statblock.new(name: 'Target', armor_class: 10, dexterity: 10)
        @target = Character.new(name: 'Target', statblock: @target_stat)

        @combat = TeamCombat.new(teams: [Team.new(name: 'A', members: [@hero]),
                                         Team.new(name: 'B', members: [@target])])
      end

      def test_battlemaster_topple_maneuver
        @hero.attacks << Attack.new(name: 'Sword', damage_dice: '1d8', relevant_stat: :strength)

        # Roll 15 (Hit), 5 (Damage), 4 (Maneuver Damage), 5 (Target Save Fail)
        mock = MockDiceRoller.new([15, 5, 4, 5, 5])
        @hero.attacks.first.instance_variable_set(:@dice_roller, mock)

        # We need to ensure the strategy chooses trip_attack (which is what topple is called in BattleMaster)
        @hero.strategy.instance_variable_set(:@maneuver_choice, :trip_attack)

        # Manually trigger turn or check strategy logic
        @hero.start_turn
        @hero.strategy.execute_turn(@hero, @combat)

        assert_predicate @target, :prone?, 'Target should be prone after Trip Attack'
      end
    end
  end
end
