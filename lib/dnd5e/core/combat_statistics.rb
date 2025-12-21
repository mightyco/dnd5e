require_relative "../simulation/result"

module Dnd5e
  module Core
    class CombatStatistics
      attr_reader :battle_wins, :initiative_wins, :initiative_battle_wins, :results

      def initialize
        @battle_wins = Hash.new(0)
        @initiative_wins = Hash.new(0)
        @initiative_battle_wins = Hash.new(0)
        @results = []
        @participating_teams = []
      end

      def update(event, data)
        case event
        when :combat_start
          if data[:combat] && data[:combat].respond_to?(:teams)
             # Build map of combatants to teams
             @combatant_team_map = {}
             data[:combat].teams.each do |team|
               team.members.each { |m| @combatant_team_map[m.name] = team }
             end
           end
        when :combat_end
          handle_combat_end(data)
        end
      end

      def handle_combat_end(data)
        winner = data[:winner]
        initiative_winner = data[:initiative_winner]

        return unless winner && initiative_winner

        # Map initiative winner to team if possible
        if @combatant_team_map && initiative_winner.respond_to?(:name) && @combatant_team_map[initiative_winner.name]
            initiative_winner = @combatant_team_map[initiative_winner.name]
        end

        winner_name = winner.name
        initiative_winner_name = initiative_winner.respond_to?(:name) ? initiative_winner.name : initiative_winner.to_s

        @battle_wins[winner_name] += 1
        @initiative_wins[initiative_winner_name] += 1
        
        if winner_name == initiative_winner_name
          @initiative_battle_wins[winner_name] += 1
        end
        
        # Store team objects if we encounter them, for reporting names later?
        # Just names are keys.
        @results << Simulation::Result.new(winner: winner, initiative_winner: initiative_winner)
      end

      def generate_report(num_simulations)
        report_string = ""
        
        # Sort by wins
        sorted_winners = @battle_wins.sort_by { |_, v| -v }
        
        sorted_winners.each do |team_name, wins|
          win_percentage = (wins.to_f / num_simulations * 100).round(1)
          report_string += "#{team_name} won #{win_percentage}% (#{wins} of #{num_simulations}) of the battles\n"
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
        
        report_string
      end
    end
  end
end
