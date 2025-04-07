require_relative "../../test_helper"
require_relative "../../../lib/dnd5e/simulation/silent_combat_result_handler"
require_relative "../../../lib/dnd5e/core/team_combat"
require_relative "../../../lib/dnd5e/core/team"
require_relative "../core/factories"

require 'logger'

module Dnd5e
  module Simulation
    class TestSilentCombatResultHandler < Minitest::Test
      include Core::Factories

      def setup
        @hero1 = CharacterFactory.create_hero
        @hero2 = CharacterFactory.create_hero
        @goblin1 = MonsterFactory.create_goblin
        @goblin2 = MonsterFactory.create_goblin

        @heroes = Core::Team.new(name: "Heroes", members: [@hero1, @hero2])
        @goblins = Core::Team.new(name: "Goblins", members: [@goblin1, @goblin2])

        @logger = Logger.new(nil)
        @handler = SilentCombatResultHandler.new

        @combat = Core::TeamCombat.new(teams: [@heroes, @goblins], logger: @logger, result_handler: @handler)
      end

      def test_handle_result
        @combat.run_combat  # Calls handler and records init
        assert_equal 1, @handler.results.size
      end

      def test_results
        @combat.run_combat
        @handler.handle_result(@combat, @heroes, @goblins)
        assert_equal @handler.results, @handler.results
      end
    end
  end
end
