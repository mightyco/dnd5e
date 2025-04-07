require_relative "../core/team"
require_relative "result"

require 'logger'

module Dnd5e
  module Simulation
    class SimulationCombatResultHandler
      attr_reader :results, :initiative_wins, :battle_wins

      def initialize
        @results = []
        @initiative_wins = Hash.new(0)
        @battle_wins = Hash.new(0)
        @initiative_battle_wins = Hash.new(0)
      end

      def handle_result(combat, winner, initiative_winner)
        result = Result.new(winner: winner, initiative_winner: initiative_winner)
        @results << result
        @initiative_wins[initiative_winner.name] += 1
        @battle_wins[winner.name] += 1
        @initiative_battle_wins[initiative_winner.name] += 1 if winner == initiative_winner
      end

      def report(num_simulations)
        report_string = ""
        @battle_wins.each do |team_name, wins|
          win_percentage = (wins.to_f / num_simulations * 100).round(1)
          report_string += "#{team_name} won #{win_percentage}% (#{wins} of #{num_simulations}) of the battles\n"
        end
        report_string += "\n"
        @initiative_wins.each do |team_name, wins|
          initiative_win_percentage = (wins.to_f / num_simulations * 100).round(1)
          battle_wins_for_team = @battle_wins[team_name]
          battle_win_percentage = 0
          if battle_wins_for_team > 0
            battle_win_percentage = (@initiative_battle_wins[team_name].to_f / battle_wins_for_team * 100).round(1)
          end
          report_string += "#{team_name} won initiative #{initiative_win_percentage}% (#{wins} of #{num_simulations}) of the time overall but #{battle_win_percentage}% of the time that they won the battle (#{@initiative_battle_wins[team_name]} of #{battle_wins_for_team})\n"
        end
        report_string
      end
    end
  end
end
