require_relative "../core/team_combat"

module Dnd5e
  module Simulation
    class MockBattleScenario
      def initialize(result_handler, teams:)
        raise ArgumentError, "MockBattleScenario requires exactly two teams" unless teams.size == 2
        @combat = Core::TeamCombat.new(teams: teams, result_handler: result_handler)
      end

      def start
        @combat.run_combat
      end
    end
  end
end
