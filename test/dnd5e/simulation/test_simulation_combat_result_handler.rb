require_relative "../../test_helper"
require_relative "../../../lib/dnd5e/simulation/simulation_combat_result_handler"
require_relative "../../../lib/dnd5e/core/team_combat"
require_relative "../core/factories"

require 'logger'

module Dnd5e
  module Simulation
    class TestSimulationCombatResultHandler < Minitest::Test
      include Core::Factories

      def setup
        @hero1 = CharacterFactory.create_hero
        @hero2 = CharacterFactory.create_hero
        @goblin1 = MonsterFactory.create_goblin
        @goblin2 = MonsterFactory.create_goblin

        @heroes = Core::Team.new(name: "Heroes", members: [@hero1, @hero2])
        @goblins = Core::Team.new(name: "Goblins", members: [@goblin1, @goblin2])

        @logger = Logger.new(nil)
        @handler = SimulationCombatResultHandler.new
        @combat = Core::TeamCombat.new(teams: [@heroes, @goblins], result_handler: @handler, logger: @logger)
      end

      def test_handle_result
        @combat.run_combat
        initiative_winner = @combat.turn_manager.turn_order.first.team
        combat_winner = @combat.winner
        assert_equal 1, @handler.results.size
        assert_equal combat_winner, @handler.results.first.winner
        assert_equal initiative_winner, @handler.results.first.initiative_winner
        assert_equal 1, @handler.initiative_wins[initiative_winner.name]
        assert_equal 1, @handler.battle_wins[combat_winner.name]
      end

      def test_report
        # Run multiple combats to simulate different initiative outcomes
        5.times do
          # Create new combatants for each combat
          hero1 = CharacterFactory.create_hero
          hero2 = CharacterFactory.create_hero
          goblin1 = MonsterFactory.create_goblin
          goblin2 = MonsterFactory.create_goblin
      
          heroes = Core::Team.new(name: "Heroes", members: [hero1, hero2])
          goblins = Core::Team.new(name: "Goblins", members: [goblin1, goblin2])
          combat = Core::TeamCombat.new(teams: [heroes, goblins], result_handler: @handler, logger: @logger)
          
          # Run the combat
          combat.run_combat
          
          # Record the result
          initiative_winner = combat.turn_manager.turn_order.first.team
          combat_winner = combat.winner
          @handler.handle_result(combat, combat_winner, initiative_winner)
        end
        
        report = @handler.report(5)
        assert_match(/won.*of 5\) of the battles/, report)
        assert_match(/won initiative/, report)
      end

    end
  end
end
