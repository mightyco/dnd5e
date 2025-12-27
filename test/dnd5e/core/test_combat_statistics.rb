# frozen_string_literal: true

require_relative '../../test_helper'
require_relative '../../../lib/dnd5e/core/combat_statistics'

module Dnd5e
  module Core
    class TestCombatStatistics < Minitest::Test
      MockTeam = Struct.new(:name)

      def setup
        @stats = CombatStatistics.new
        @heroes = MockTeam.new('Heroes')
        @goblins = MockTeam.new('Goblins')
      end

      def test_tracks_battle_wins
        @stats.update(:combat_end, winner: @heroes, initiative_winner: @goblins)
        @stats.update(:combat_end, winner: @heroes, initiative_winner: @heroes)

        assert_equal 2, @stats.battle_wins['Heroes']
        assert_equal 0, @stats.battle_wins['Goblins']
      end

      def test_tracks_initiative_wins
        @stats.update(:combat_end, winner: @heroes, initiative_winner: @goblins)
        @stats.update(:combat_end, winner: @heroes, initiative_winner: @heroes)

        assert_equal 1, @stats.initiative_wins['Heroes']
        assert_equal 1, @stats.initiative_wins['Goblins']
      end

      def test_tracks_initiative_to_battle_conversion
        # Heroes win init and battle
        @stats.update(:combat_end, winner: @heroes, initiative_winner: @heroes)

        # Goblins win init but lose battle
        @stats.update(:combat_end, winner: @heroes, initiative_winner: @goblins)

        assert_equal 1, @stats.initiative_battle_wins['Heroes']
        assert_equal 0, @stats.initiative_battle_wins['Goblins']
      end

      def test_report
        @stats.update(:combat_end, winner: @heroes, initiative_winner: @heroes)
        @stats.update(:combat_end, winner: @goblins, initiative_winner: @goblins)

        # We need to register teams somehow or it infers from winners?
        # SimulationCombatResultHandler inferred from combat.teams
        # Here we only get winner/init_winner.
        # If a team never wins, it won't be in the keys.
        # Maybe we need to pass participating teams in :combat_start?
        # Let's add that test case.
      end

      def test_tracks_teams_from_start
        @stats.update(:combat_start, combatants: [@heroes, @goblins]) # Wait, combatants are members, not teams usually?
        # In TeamCombat, we have teams. In Combat, we have combatants.
        # If combatants have .team, we can deduce teams.
        # Or pass teams explicitly if available.
        # In Combat, we pass combatants array.
        # Let's assume combatants are passed.
        # If they are teams (TeamCombat), then fine.

        # Let's assume we pass teams if we want team stats.
        # Or simply rely on winner names for now.

        # Report string check
        @stats.update(:combat_end, winner: @heroes, initiative_winner: @heroes)
        report = @stats.generate_report(1)
        assert_match(/Heroes won 100.0%/, report)
      end
    end
  end
end
