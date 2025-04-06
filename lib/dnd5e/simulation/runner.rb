require_relative "../core/team_combat"
require_relative "silent_combat_result_handler"
require_relative "simulation_combat_result_handler"

require 'logger'

module Dnd5e
  module Simulation
    class Runner
      attr_reader :battle_scenario, :num_simulations, :results, :result_handler

      def initialize(battle_scenario, num_simulations:, result_handler:, teams:, logger: Logger.New($stdout))
        @battle_scenario = battle_scenario
        @num_simulations = num_simulations
        @results = []
        @result_handler = result_handler
        @teams = teams
        @logger = logger
        @logger.formatter = proc do |severity, datetime, progname, msg|
          "#{msg}\n"
        end
      end

      def run_battle
        scenario = @battle_scenario.new(@result_handler, teams: @teams, logger: @logger)
        scenario.start
        @results << @result_handler.results.last
      end

      def run
        @num_simulations.times { run_battle }
      end

      def generate_report
        puts "Simulation Report"
        puts "-----------------"
        puts "Sample Results:"
        winners = {}
        @result_handler.results.each do |result|
          winners[result.winner.name] ||= []
          winners[result.winner.name] << result
        end
        winners.each do |team_name, results|
          sample_result = results.sample
          puts "  Winner: #{sample_result.winner.name}, Initiative Winner: #{sample_result.initiative_winner.name}"
        end
        puts "-----------------"
        if @result_handler.is_a?(SimulationCombatResultHandler)
          puts @result_handler.report(@num_simulations)
        end
      end
    end
  end
end
