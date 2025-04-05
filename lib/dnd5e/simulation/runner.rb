require_relative "result"
require_relative "../core/team_combat"

module Dnd5e
  module Simulation
    class Runner
      attr_reader :battle_scenario, :num_simulations, :results

      def initialize(battle_scenario, num_simulations: 100)
        @battle_scenario = battle_scenario
        @num_simulations = num_simulations
        @results = []
      end

      def run
        @num_simulations.times do
          @results << run_battle
        end
      end

      def run_battle
        # Create a new instance of the battle scenario for each simulation
        battle = @battle_scenario.new

        # Run the battle and get the result
        battle.start
      end

      def generate_report
        puts "Simulation Report:"
        puts "-------------------"
        puts "Number of Simulations: #{@num_simulations}"
        puts ""

        # Calculate win rates
        team_wins = Hash.new(0)
        @results.each do |result|
          team_wins[result.winner.name] += 1
        end

        puts "Win Rates:"
        team_wins.each do |team_name, wins|
          win_rate = (wins.to_f / @num_simulations * 100).round(2)
          puts "#{team_name}: #{win_rate}% (#{wins} wins)"
        end
        puts ""

        # Calculate initiative impact
        initiative_wins = Hash.new(0)
        @results.each do |result|
          initiative_wins[result.initiative_winner.name] += 1 if result.winner == result.initiative_winner
        end

        puts "Initiative Impact:"
        initiative_wins.each do |team_name, wins|
          initiative_win_rate = (wins.to_f / @num_simulations * 100).round(2)
          puts "#{team_name} won initiative and the battle: #{initiative_win_rate}% (#{wins} wins)"
        end
      end
    end
  end
end
