require_relative "../core/team_combat"
require_relative "silent_combat_result_handler"
require_relative "simulation_combat_result_handler"

require 'logger'

module Dnd5e
  module Simulation
    class Runner
      attr_reader :battle_scenario, :num_simulations, :results, :result_handler, :teams

      def initialize(battle_scenario, num_simulations:, result_handler:, teams:, logger: Logger.new($stdout))
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
        # Re-create teams for each battle
        new_teams = create_teams
        scenario = Core::TeamCombat.new(teams: new_teams, result_handler: @result_handler, logger: @logger)
        scenario.run_combat
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

      private

      def create_teams
        # Create new instances of teams and their members
        @teams.map do |team|
          new_members = team.members.map do |member|
            # Access statblock attributes correctly
            new_statblock = member.statblock.class.new(
              name: member.statblock.name,
              strength: member.statblock.strength,
              dexterity: member.statblock.dexterity,
              constitution: member.statblock.constitution,
              intelligence: member.statblock.intelligence,
              wisdom: member.statblock.wisdom,
              charisma: member.statblock.charisma,
              hit_die: member.statblock.hit_die,
              level: member.statblock.level
            )
            new_statblock.hit_points = new_statblock.calculate_hit_points
            member.class.new(name: member.name, statblock: new_statblock, attacks: member.attacks)
          end
          Core::Team.new(name: team.name, members: new_members)
        end
      end

    end
  end
end
