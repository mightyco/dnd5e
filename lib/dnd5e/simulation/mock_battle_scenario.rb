require_relative "../core/team_combat"

require 'logger'

module Dnd5e
  module Simulation
    class MockBattleScenario
      def initialize(result_handler, teams:, logger: Logger.new($stdout))
        raise ArgumentError, "MockBattleScenario requires exactly two teams" unless teams.size == 2
        @combat = Core::TeamCombat.new(teams: teams, result_handler: result_handler, logger: logger)
        @logger = logger
        @logger.formatter = proc do |severity, datetime, progname, msg|
          "#{msg}\n"
        end
      end

      def start
        @combat.run_combat
      end
    end
  end
end
