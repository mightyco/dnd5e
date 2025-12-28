# frozen_string_literal: true

require_relative '../../test_helper'
require_relative '../../../lib/dnd5e/simulation/simulation_combat_result_handler'
require_relative '../../../lib/dnd5e/core/combat'
require_relative '../../../lib/dnd5e/core/team'
require_relative '../../../lib/dnd5e/builders/character_builder'
require_relative '../../../lib/dnd5e/core/statblock'
require_relative '../../../lib/dnd5e/core/attack'
require_relative '../../../lib/dnd5e/core/dice'

module Dnd5e
  module Simulation
    class TestSimulationCombatResultHandler < Minitest::Test
      def setup
        @handler = SimulationCombatResultHandler.new
        create_teams
      end

      def create_teams
        sword = Core::Attack.new(name: 'Sword', damage_dice: Core::Dice.new(1, 8), relevant_stat: :strength)
        hero = Builders::CharacterBuilder.new(name: 'Hero').as_fighter.with_attack(sword).build
        goblin = Builders::CharacterBuilder.new(name: 'Goblin').as_fighter.with_attack(sword).build

        @team1 = Core::Team.new(name: 'Team 1', members: [hero])
        @team2 = Core::Team.new(name: 'Team 2', members: [goblin])

        @combat_data = { combat: Struct.new(:teams).new([@team1, @team2]) }
        @winner = hero
        @loser = goblin
      end

      def test_initialization
        assert_empty @handler.results
        assert_empty @handler.initiative_wins
        assert_empty @handler.battle_wins
      end

      def test_handle_result
        @handler.update(:combat_start, @combat_data)
        update_handler_with_results

        assert_equal 2, @handler.results.size
        # Winners are mapped to teams
        assert_equal 2, @handler.battle_wins['Team 1']
        assert_equal 1, @handler.initiative_wins['Team 2']
        assert_equal 1, @handler.initiative_wins['Team 1']
      end

      def test_report
        @handler.update(:combat_start, @combat_data)
        5.times { @handler.update(:combat_end, winner: @winner, initiative_winner: @winner) }

        output = @handler.report(5)
        # Regex needs to match actual output structure including newlines
        assert_match(/Team 1 won 100.0% \(5 of 5\) of the battles/, output)
        assert_match(/Team 2 won 0.0% \(0 of 5\) of the battles/, output)
        assert_match(/Team 1 won initiative 100.0% \(5 of 5\) of the time overall/, output)
      end

      private

      def update_handler_with_results
        @handler.update(:combat_end, winner: @winner, initiative_winner: @loser)
        @handler.update(:combat_end, winner: @winner, initiative_winner: @winner)
      end
    end
  end
end
