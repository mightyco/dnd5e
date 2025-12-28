# frozen_string_literal: true

require_relative '../simulation/result'

module Dnd5e
  module Core
    # Collects and calculates statistics from combat simulations.
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
          handle_combat_start(data)
        when :combat_end
          handle_combat_end(data)
        end
      end

      def handle_combat_start(data)
        return unless data[:combat].respond_to?(:teams)

        # Build map of combatants to teams
        @combatant_team_map = {}
        data[:combat].teams.each do |team|
          team.members.each { |m| @combatant_team_map[m.name] = team }
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

        record_wins(winner, initiative_winner)
        @results << Simulation::Result.new(winner: winner, initiative_winner: initiative_winner)
      end

      def generate_report(num_simulations)
        report_parts = []
        report_parts << generate_battle_wins_report(num_simulations)
        report_parts << generate_initiative_wins_report(num_simulations)
        report_parts.join("\n")
      end

      private

      def record_wins(winner, initiative_winner)
        winner_name = winner.name
        initiative_winner_name = initiative_winner.respond_to?(:name) ? initiative_winner.name : initiative_winner.to_s

        @battle_wins[winner_name] += 1
        @initiative_wins[initiative_winner_name] += 1

        @initiative_battle_wins[winner_name] += 1 if winner_name == initiative_winner_name
      end

      def generate_battle_wins_report(num_simulations)
        sorted_winners = @battle_wins.sort_by { |_, v| -v }
        sorted_winners.map do |team_name, wins|
          win_percentage = (wins.to_f / num_simulations * 100).round(1)
          "#{team_name} won #{win_percentage}% (#{wins} of #{num_simulations}) of the battles"
        end.join("\n")
      end

      def generate_initiative_wins_report(num_simulations)
        report = @initiative_wins.map do |team_name, wins|
          format_initiative_stat(team_name, wins, num_simulations)
        end.join("\n")
        "#{report}\n"
      end

      def format_initiative_stat(team_name, wins, num_simulations)
        init_win_pct = (wins.to_f / num_simulations * 100).round(1)
        battle_wins = @battle_wins[team_name] || 0
        battle_win_pct = calculate_battle_win_pct(team_name, battle_wins)
        init_wins_in_battles = @initiative_battle_wins[team_name] || 0

        "#{team_name} won initiative #{init_win_pct}% (#{wins} of #{num_simulations}) " \
          "of the time overall but #{battle_win_pct}% of the time that they won the battle " \
          "(#{init_wins_in_battles} of #{battle_wins})"
      end

      def calculate_battle_win_pct(team_name, battle_wins)
        return 0 unless battle_wins.positive?

        (@initiative_battle_wins[team_name].to_f / battle_wins * 100).round(1)
      end
    end
  end
end
