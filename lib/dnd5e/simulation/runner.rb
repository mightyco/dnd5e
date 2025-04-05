require_relative "../core/team_combat"
require_relative "silent_combat_result_handler"
require_relative "simulation_combat_result_handler"

module Dnd5e
  module Simulation
    class Runner
      attr_reader :battle_scenario, :num_simulations, :results, :result_handler

      def initialize(battle_scenario, num_simulations:, result_handler:, teams:)
        @battle_scenario = battle_scenario
        @num_simulations = num_simulations
        @results = []
        @result_handler = result_handler
        @teams = teams
      end

      def run_battle
        scenario = @battle_scenario.new(@result_handler, teams: @teams)
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
        sample_results = @result_handler.results.sample(5)
        sample_results.each do |result|
          puts "  Winner: #{result.winner.name}, Initiative Winner: #{result.initiative_winner.name}"
        end
        puts "-----------------"
        if @result_handler.is_a?(SimulationCombatResultHandler)
          puts @result_handler.report(@num_simulations)
        end
      end
    end
  end
end
