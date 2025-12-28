# frozen_string_literal: true

require_relative '../../test_helper'
require_relative '../../../lib/dnd5e/simulation/runner'
require_relative '../../../lib/dnd5e/simulation/simulation_combat_result_handler'
require_relative '../../../lib/dnd5e/simulation/scenario_builder'
require_relative 'test_runner'

module Dnd5e
  module Simulation
    class TestRunnerReports < Minitest::Test
      include RunnerTestSetup

      def test_simulation_report_initiative_wins
        attempts = 1000
        run_simulation(attempts)
        report = @result_handler.report(attempts)

        verify_report_structure(report, attempts)
        verify_report_numbers(report, attempts)
      end

      private

      def run_simulation(attempts)
        @result_handler = SimulationCombatResultHandler.new
        scenario = ScenarioBuilder.new(num_simulations: attempts).with_team(@heroes).with_team(@goblins).build
        runner = Runner.new(scenario: scenario, result_handler: @result_handler, logger: @logger)
        runner.run
      end

      def verify_report_structure(report, attempts)
        assert_match(/won \d+\.\d+% \(\d+ of #{attempts}\) of the battles/, report)
        assert_match(/won initiative \d+\.\d+% \(\d+ of #{attempts}\) of the time overall/, report)
        assert_match(/but \d+\.\d+% of the time that they won the battle \(\d+ of \d+\)/, report)
      end

      def verify_report_numbers(report, attempts)
        heroes_data = parse_team_data(report, 'Heroes', attempts)
        goblins_data = parse_team_data(report, 'Goblins', attempts)

        assert_in_delta(heroes_data[:wins_pct], heroes_data[:wins_count].to_f / attempts * 100, 0.1)
        assert_in_delta(goblins_data[:wins_pct], goblins_data[:wins_count].to_f / attempts * 100, 0.1)

        verify_team_initiative_stats(heroes_data)
        verify_team_initiative_stats(goblins_data)
      end

      def parse_team_data(report, team, attempts)
        wins_match = report.match(/#{team} won (\d+\.\d+)% \((\d+) of #{attempts}\) of the battles/)

        p1 = "#{team} won initiative (\\d+\\.\\d+)% \\(\\d+ of #{attempts}\\) of the time overall"
        p2 = '(?: but (\\d+\\.\\d+)% of the time that they won the battle \\((\\d+) of (\\d+)\\))?'
        init_match = report.match(Regexp.new(p1 + p2))

        { wins_pct: wins_match[1].to_f, wins_count: wins_match[2].to_i,
          init_won_when_won_pct: init_match[2]&.to_f, init_won_when_won_count: init_match[3]&.to_i,
          wins_count_from_init: init_match[4]&.to_i }
      end

      def verify_team_initiative_stats(data)
        if data[:wins_count].positive?
          assert_equal(data[:wins_count], data[:wins_count_from_init])
          assert_in_delta(data[:init_won_when_won_pct],
                          data[:init_won_when_won_count].to_f / data[:wins_count] * 100, 0.1)
        else
          assert_nil(data[:wins_count_from_init])
          assert_nil(data[:init_won_when_won_pct])
        end
      end
    end
  end
end
