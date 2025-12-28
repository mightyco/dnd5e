# frozen_string_literal: true

require_relative '../simulation/scenario_builder'
require_relative '../simulation/runner'
require_relative '../simulation/silent_combat_result_handler'

module Dnd5e
  module Experiments
    # Executes an experiment by running simulations for each combination of variables.
    class Runner
      def initialize(experiment)
        @experiment = experiment
        @results = []
      end

      def run
        combinations = generate_combinations
        print_header(combinations.size)

        combinations.each do |combo|
          # Map values back to names
          params = @experiment.variables.keys.zip(combo).to_h
          run_scenario(params)
        end

        print_summary
      end

      private

      def generate_combinations
        variable_values = @experiment.variables.values
        # Cartesian product of all variable values
        combinations = variable_values.first.product(*variable_values.drop(1))
        # If there are no variables, run once with empty params
        combinations.empty? && variable_values.empty? ? [[]] : combinations
      end

      def print_header(total_scenarios)
        puts "Running Experiment: #{@experiment.name}"
        puts "Total Scenarios: #{total_scenarios}"
        puts "Simulations per Scenario: #{@experiment.simulation_count}"
        puts '-' * 40
      end

      def run_scenario(params)
        control_team, test_team = build_teams(params)
        handler = execute_simulation(control_team, test_team)
        analyze_results(handler, control_team, test_team, params)
      end

      def build_teams(params)
        control_team = @experiment.control_group_block.call(params)
        test_team = @experiment.test_group_block.call(params)
        [control_team, test_team]
      end

      def execute_simulation(control_team, test_team)
        builder = Simulation::ScenarioBuilder.new(num_simulations: @experiment.simulation_count)
        builder.with_team(control_team)
        builder.with_team(test_team)
        scenario = builder.build

        handler = Simulation::SilentCombatResultHandler.new
        runner = Simulation::Runner.new(scenario: scenario, result_handler: handler)
        runner.run
        handler
      end

      def analyze_results(handler, control_team, test_team, params)
        control_wins = handler.results.count { |r| r.winner&.name == control_team.name }
        test_wins = handler.results.count { |r| r.winner&.name == test_team.name }

        result = create_result_hash(params, control_team, test_team, control_wins, test_wins)

        @results << result
        print_progress(result)
      end

      def create_result_hash(params, control_team, test_team, control_wins, test_wins)
        {
          params: params,
          control_team: control_team.name, test_team: test_team.name,
          control_wins: control_wins, test_wins: test_wins,
          total: @experiment.simulation_count
        }
      end

      def print_progress(result)
        params_str = format_params(result[:params])
        control_pct = calculate_percentage(result[:control_wins], result[:total])
        test_pct = calculate_percentage(result[:test_wins], result[:total])

        puts "[#{params_str}] #{result[:control_team]}: #{control_pct}% | #{result[:test_team]}: #{test_pct}%"
      end

      def format_params(params)
        params.map { |k, v| "#{k}: #{v}" }.join(', ')
      end

      def calculate_percentage(wins, total)
        (wins.to_f / total * 100).round(1)
      end

      def print_summary
        puts '-' * 40
        puts 'Experiment Complete.'
        # Could export to CSV here in the future
      end
    end
  end
end
