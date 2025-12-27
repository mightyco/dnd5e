# frozen_string_literal: true

require_relative '../core/team_combat'
require_relative 'silent_combat_result_handler'
require_relative 'simulation_combat_result_handler'
require_relative 'scenario'

require 'logger'

module Dnd5e
  module Simulation
    class Runner
      attr_reader :scenario, :results, :result_handler, :logger

      def initialize(scenario:, result_handler:, logger: Logger.new($stdout))
        @scenario = scenario
        @results = []
        @result_handler = result_handler
        @logger = logger
        @logger.formatter = proc do |_severity, _datetime, _progname, msg|
          "#{msg}\n"
        end
      end

      def run_battle
        # Re-create teams for each battle
        new_teams = create_teams
        # We don't need to pass result_handler anymore if we rely on observer
        # But wait, create_teams creates new TeamCombat.
        # We need to attach the result_handler (which should be an observer) to the new TeamCombat.

        scenario = Core::TeamCombat.new(teams: new_teams)
        scenario.add_observer(@result_handler) if @result_handler.respond_to?(:update)
        scenario.run_combat

        # Add result to local results if available
        return unless @result_handler.respond_to?(:results) && @result_handler.results.any?

        @results << @result_handler.results.last
      end

      def run
        @scenario.num_simulations.times { run_battle }
      end

      def generate_report
        puts 'Simulation Report'
        puts '-----------------'

        # Support both old and new handlers
        results_source = @result_handler.respond_to?(:results) ? @result_handler.results : @results

        if results_source.any?
          puts 'Sample Results:'
          winners = {}
          results_source.each do |result|
            winners[result.winner.name] ||= []
            winners[result.winner.name] << result
          end
          winners.each_value do |results|
            sample_result = results.sample
            puts "  Winner: #{sample_result.winner.name}, Initiative Winner: #{sample_result.initiative_winner.name}"
          end
          puts '-----------------'
        end

        if @result_handler.respond_to?(:generate_report)
          puts @result_handler.generate_report(@scenario.num_simulations)
        elsif @result_handler.respond_to?(:report)
          # The handler's report method logs to its own logger AND returns the string.
          # We avoid 'puts' here to prevent duplicate output since the handler logs it.
          @result_handler.report(@scenario.num_simulations)
        end
      end

      private

      def create_teams
        # Create new instances of teams and their members
        @scenario.teams.map do |team|
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
              level: member.statblock.level,
              saving_throw_proficiencies: member.statblock.saving_throw_proficiencies,
              equipped_armor: member.statblock.equipped_armor,
              equipped_shield: member.statblock.equipped_shield
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
