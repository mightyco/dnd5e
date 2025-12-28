# frozen_string_literal: true

require_relative '../../test_helper'
require_relative '../../../lib/dnd5e/simulation/silent_combat_result_handler'
require_relative '../../../lib/dnd5e/core/combat'
require_relative '../../../lib/dnd5e/core/team'
require_relative '../../../lib/dnd5e/builders/character_builder'
require_relative '../../../lib/dnd5e/core/statblock'
require_relative '../../../lib/dnd5e/core/attack'
require_relative '../../../lib/dnd5e/core/dice'

module Dnd5e
  module Simulation
    class TestSilentCombatResultHandler < Minitest::Test
      def setup
        @handler = SilentCombatResultHandler.new
        create_teams
      end

      def create_teams
        sword = Core::Attack.new(name: 'Sword', damage_dice: Core::Dice.new(1, 8), relevant_stat: :strength)
        hero = Builders::CharacterBuilder.new(name: 'Hero').as_fighter.with_attack(sword).build
        goblin = Builders::CharacterBuilder.new(name: 'Goblin').as_fighter.with_attack(sword).build

        @team1 = Core::Team.new(name: 'Team 1', members: [hero])
        @team2 = Core::Team.new(name: 'Team 2', members: [goblin])
        @combat_data = { combat: Struct.new(:teams).new([@team1, @team2]), combatants: [hero, goblin] }
      end

      def test_initialization
        assert_empty @handler.results
      end

      def test_handle_result
        @handler.update(:combat_start, @combat_data)
        winner = @team1.members.first
        initiative_winner = @team2.members.first

        @handler.update(:combat_end, winner: winner, initiative_winner: initiative_winner)

        assert_equal 1, @handler.results.size
        result = @handler.results.first
        # Winner should be mapped to team
        assert_equal @team1, result.winner
        assert_equal @team2, result.initiative_winner
      end

      def test_results
        @handler.update(:combat_start, @combat_data)
        winner = @team1.members.first

        3.times do
          @handler.update(:combat_end, winner: winner, initiative_winner: winner)
        end

        assert_equal 3, @handler.results.size
      end
    end
  end
end
