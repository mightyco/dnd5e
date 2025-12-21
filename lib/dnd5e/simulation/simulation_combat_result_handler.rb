require_relative "../core/team"
require_relative "result"
require_relative "combat_result_handler"

require 'logger'

module Dnd5e
  module Simulation
    class SimulationCombatResultHandler < CombatResultHandler
      attr_reader :results, :initiative_wins, :battle_wins, :logger

      def initialize(logger: Logger.new(nil))
        super()
        @results = []
        @initiative_wins = Hash.new(0)
        @battle_wins = Hash.new(0)
        @initiative_battle_wins = Hash.new(0)
        @teams = []
        @logger = logger
      end

      def update(event, data)
        if event == :combat_start
           if data[:combat] && data[:combat].respond_to?(:teams)
             @teams = data[:combat].teams
             @combatant_team_map = {}
             @teams.each do |team|
               team.members.each { |m| @combatant_team_map[m.name] = team }
             end
           end
        elsif event == :combat_end
          initiative_winner = data[:initiative_winner]
          if @combatant_team_map && initiative_winner.respond_to?(:name) && @combatant_team_map[initiative_winner.name]
            initiative_winner = @combatant_team_map[initiative_winner.name]
          end
          handle_result(nil, data[:winner], initiative_winner)
        end
      end

      def handle_result(combat, winner, initiative_winner)
        # combat parameter is deprecated/unused now if coming from observer
        # @teams = combat.teams unless @teams.any? 
        # We need a way to track teams if they are not passed.
        
        result = Result.new(winner: winner, initiative_winner: initiative_winner)
        @results << result
        @initiative_wins[initiative_winner.name] += 1
        @battle_wins[winner.name] += 1
        @initiative_battle_wins[initiative_winner.name] += 1 if winner == initiative_winner
      end

      def report(num_simulations)
        report_string = ""
        # Ensure all teams are reported, even if they have 0 wins
        @teams.each do |team|
          wins = @battle_wins[team.name] || 0
          win_percentage = (wins.to_f / num_simulations * 100).round(1)
          report_string += "#{team.name} won #{win_percentage}% (#{wins} of #{num_simulations}) of the battles\n"
        end
        report_string += "\n"
        @initiative_wins.each do |team_name, wins|
          initiative_win_percentage = (wins.to_f / num_simulations * 100).round(1)
          battle_wins_for_team = @battle_wins[team_name] || 0
          battle_win_percentage = 0
          if battle_wins_for_team > 0
            battle_win_percentage = (@initiative_battle_wins[team_name].to_f / battle_wins_for_team * 100).round(1)
          end
          report_string += "#{team_name} won initiative #{initiative_win_percentage}% (#{wins} of #{num_simulations}) of the time overall but #{battle_win_percentage}% of the time that they won the battle (#{@initiative_battle_wins[team_name] || 0} of #{battle_wins_for_team})\n"
        end
        logger.info report_string
        report_string
      end
    end
  end
end
