# frozen_string_literal: true

require_relative '../core/team'
require_relative 'result'
require_relative 'combat_result_handler'

require 'logger'

module Dnd5e
  module Simulation
    # Handles combat results for simulations, tracking detailed statistics.
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
        case event
        when :combat_start
          handle_combat_start(data)
        when :combat_end
          handle_combat_end(data)
        end
      end

      def handle_result(_combat, winner, initiative_winner)
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
        report_string = ''
        report_string += generate_battle_wins_report(num_simulations)
        report_string += "\n"
        report_string += generate_initiative_wins_report(num_simulations)

        logger.info report_string
        report_string
      end

      private

      def handle_combat_start(data)
        return unless data[:combat].respond_to?(:teams)

        @teams = data[:combat].teams
        @combatant_team_map = {}
        @teams.each do |team|
          team.members.each { |m| @combatant_team_map[m.name] = team }
        end
      end

      def handle_combat_end(data)
        initiative_winner = data[:initiative_winner]
        winner = data[:winner]

        if @combatant_team_map
          if initiative_winner.respond_to?(:name) && @combatant_team_map[initiative_winner.name]
            initiative_winner = @combatant_team_map[initiative_winner.name]
          end
          winner = @combatant_team_map[winner.name] if winner.respond_to?(:name) && @combatant_team_map[winner.name]
        end

        handle_result(nil, winner, initiative_winner)
      end

      def generate_battle_wins_report(num_simulations)
        # Ensure all teams are reported, even if they have 0 wins
        @teams.map do |team|
          wins = @battle_wins[team.name] || 0
          win_percentage = (wins.to_f / num_simulations * 100).round(1)
          "#{team.name} won #{win_percentage}% (#{wins} of #{num_simulations}) of the battles\n"
        end.join
      end

      def generate_initiative_wins_report(num_simulations)
        @initiative_wins.map do |team_name, wins|
          format_initiative_stat(team_name, wins, num_simulations)
        end.join
      end

      def format_initiative_stat(team_name, wins, num_simulations)
        init_win_pct = (wins.to_f / num_simulations * 100).round(1)
        battle_wins = @battle_wins[team_name] || 0
        battle_win_pct = calculate_battle_win_pct(team_name, battle_wins)
        init_wins_in_battles = @initiative_battle_wins[team_name] || 0

        "#{team_name} won initiative #{init_win_pct}% (#{wins} of #{num_simulations}) " \
          "of the time overall but #{battle_win_pct}% of the time that they won the battle " \
          "(#{init_wins_in_battles} of #{battle_wins})\n"
      end

      def calculate_battle_win_pct(team_name, battle_wins)
        return 0 unless battle_wins.positive?

        (@initiative_battle_wins[team_name].to_f / battle_wins * 100).round(1)
      end
    end
  end
end
