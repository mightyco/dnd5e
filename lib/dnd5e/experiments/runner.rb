require_relative "../simulation/scenario_builder"
require_relative "../simulation/runner"
require_relative "../simulation/silent_combat_result_handler"

module Dnd5e
  module Experiments
    class Runner
      def initialize(experiment)
        @experiment = experiment
        @results = []
      end

      def run
        variable_names = @experiment.variables.keys
        variable_values = @experiment.variables.values

        # Cartesian product of all variable values
        combinations = variable_values.first.product(*variable_values.drop(1))
        
        # If there's only one variable, product returns arrays of single items, which is correct.
        # If there are no variables, run once with empty params?
        combinations = [[]] if combinations.empty? && variable_values.empty?

        puts "Running Experiment: #{@experiment.name}"
        puts "Total Scenarios: #{combinations.size}"
        puts "Simulations per Scenario: #{@experiment.simulation_count}"
        puts "-" * 40

        combinations.each do |combo|
          # Map values back to names
          params = Hash[variable_names.zip(combo)]
          
          run_scenario(params)
        end
        
        print_summary
      end

      private

      def run_scenario(params)
        # Build Teams
        control_team = @experiment.control_group_block.call(params)
        test_team = @experiment.test_group_block.call(params)

        # Build Scenario
        builder = Simulation::ScenarioBuilder.new(num_simulations: @experiment.simulation_count)
        builder.with_team(control_team)
        builder.with_team(test_team)
        scenario = builder.build

        # Run Simulation
        handler = Simulation::SilentCombatResultHandler.new
        runner = Simulation::Runner.new(scenario: scenario, result_handler: handler)
        runner.run

        # Analyze Results
        control_wins = handler.results.count { |r| r.winner.name == control_team.name }
        test_wins = handler.results.count { |r| r.winner.name == test_team.name }
        
        result = {
          params: params,
          control_team: control_team.name,
          test_team: test_team.name,
          control_wins: control_wins,
          test_wins: test_wins,
          total: @experiment.simulation_count
        }
        
        @results << result
        print_progress(result)
      end

      def print_progress(result)
        params_str = result[:params].map { |k, v| "#{k}: #{v}" }.join(", ")
        control_pct = (result[:control_wins].to_f / result[:total] * 100).round(1)
        test_pct = (result[:test_wins].to_f / result[:total] * 100).round(1)
        
        puts "[#{params_str}] #{result[:control_team]}: #{control_pct}% | #{result[:test_team]}: #{test_pct}%"
      end

      def print_summary
        puts "-" * 40
        puts "Experiment Complete."
        # Could export to CSV here in the future
      end
    end
  end
end

