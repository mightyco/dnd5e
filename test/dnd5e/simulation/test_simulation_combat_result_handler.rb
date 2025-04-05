require_relative "../../test_helper"
require_relative "../../../lib/dnd5e/simulation/simulation_combat_result_handler"
require_relative "../../../lib/dnd5e/core/team_combat"
require_relative "../core/factories"

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
        @combat = Core::TeamCombat.new(teams: [@heroes, @goblins])
        @handler = SimulationCombatResultHandler.new
      end

      def test_handle_result
        @combat.roll_initiative
        @handler.handle_result(@combat, @heroes, @goblins)
        assert_equal 1, @handler.results.size
        assert_equal @heroes, @handler.results.first.winner
        assert_equal @goblins, @handler.results.first.initiative_winner
        assert_equal 1, @handler.initiative_wins[@goblins.name]
        assert_equal 1, @handler.battle_wins[@heroes.name]
      end

      def test_report
        @combat.roll_initiative
        @handler.handle_result(@combat, @heroes, @goblins)
        @handler.handle_result(@combat, @goblins, @heroes)
        @handler.handle_result(@combat, @heroes, @heroes)
        @handler.handle_result(@combat, @goblins, @goblins)
        @handler.handle_result(@combat, @heroes, @heroes)
        report = @handler.report(5)
        assert_match(/Heroes won initiative/, report)
        assert_match(/Goblins won initiative/, report)
      end
    end
  end
end
