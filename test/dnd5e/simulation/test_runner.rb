require_relative "../../test_helper"
require_relative "../../../lib/dnd5e/simulation/runner"
require_relative "../../../lib/dnd5e/simulation/silent_combat_result_handler"
require_relative "../../../lib/dnd5e/simulation/simulation_combat_result_handler"
require_relative "../../../lib/dnd5e/core/team"
require_relative "../core/factories"

require "logger"

module Dnd5e
  module Simulation
    class TestRunner < Minitest::Test
      include Core::Factories

      def setup
        @hero1 = CharacterFactory.create_hero
        @hero2 = CharacterFactory.create_hero
        @goblin1 = MonsterFactory.create_goblin
        @goblin2 = MonsterFactory.create_goblin

        @heroes = Core::Team.new(name: "Heroes", members: [@hero1, @hero2])
        @goblins = Core::Team.new(name: "Goblins", members: [@goblin1, @goblin2])
        @teams = [@heroes, @goblins]

        @logger = Logger.new(nil)
      end

      def test_runner_initialization
        runner = Runner.new(nil, num_simulations: 50, result_handler: SilentCombatResultHandler.new, teams: @teams, logger: @logger)
        assert_equal 50, runner.num_simulations
        assert_empty runner.results
      end

      def test_run_battle
        result_handler = SilentCombatResultHandler.new
        runner = Runner.new(nil, num_simulations: 1, result_handler: result_handler, teams: @teams, logger: @logger)
        runner.run_battle
        assert_equal 1, runner.results.size
        assert_instance_of Result, runner.results.first
      end

      def test_run
        result_handler = SilentCombatResultHandler.new
        runner = Runner.new(nil, num_simulations: 5, result_handler: result_handler, teams: @teams, logger: @logger)
        runner.run
        assert_equal 5, runner.results.size
        runner.results.each do |result|
          assert_instance_of Result, result
        end
      end

      def test_generate_report
        result_handler = SimulationCombatResultHandler.new
        runner = Runner.new(nil, num_simulations: 5, result_handler: result_handler, teams: @teams, logger: @logger)
        runner.run
        assert_output(/Simulation Report/) { runner.generate_report }
      end

      def test_simulation_resets_between_runs
        attempts = 100
        # Create a new result handler for this test
        result_handler = SimulationCombatResultHandler.new

        # Create a new runner for this test
        runner = Runner.new(
          nil,
          num_simulations: attempts,
          result_handler: result_handler,
          teams: @teams,
          logger: @logger
        )

        # Run the simulation
        runner.run

        # Check if the results are different
        assert_equal attempts, result_handler.results.size

        # Check if there is a mix of winners
        winners = result_handler.results.map(&:winner).uniq
        assert_operator winners.size, :>=, 2, "Expected at least two different winners in #{attempts} simulations"
      end

      def test_simulation_report_initiative_wins
        attempts = 1000
        result_handler = SimulationCombatResultHandler.new
        runner = Runner.new(nil, num_simulations: attempts, result_handler: result_handler, teams: @teams, logger: @logger)
        runner.run
        report = result_handler.report(attempts)

        # Check if the report contains the correct information
        assert_match(/won \d+\.\d+% \(\d+ of #{attempts}\) of the battles/, report)
        assert_match(/won initiative \d+\.\d+% \(\d+ of #{attempts}\) of the time overall/, report)
        assert_match(/but \d+\.\d+% of the time that they won the battle \(\d+ of \d+\)/, report)

        # Check if the numbers are consistent
        heroes_wins_match = report.match(/Heroes won (\d+\.\d+)% \((\d+) of #{attempts}\) of the battles/)
        goblins_wins_match = report.match(/Goblins won (\d+\.\d+)% \((\d+) of #{attempts}\) of the battles/)
        heroes_initiative_wins_match = report.match(/Heroes won initiative (\d+\.\d+)% \(\d+ of #{attempts}\) of the time overall(?: but (\d+\.\d+)% of the time that they won the battle \((\d+) of (\d+)\))?/)
        goblins_initiative_wins_match = report.match(/Goblins won initiative (\d+\.\d+)% \(\d+ of #{attempts}\) of the time overall(?: but (\d+\.\d+)% of the time that they won the battle \((\d+) of (\d+)\))?/)

        puts report
        refute_nil heroes_wins_match
        refute_nil goblins_wins_match
        refute_nil heroes_initiative_wins_match
        refute_nil goblins_initiative_wins_match

        heroes_wins_percentage = heroes_wins_match[1].to_f
        heroes_wins_count = heroes_wins_match[2].to_i
        goblins_wins_percentage = goblins_wins_match[1].to_f
        goblins_wins_count = goblins_wins_match[2].to_i

        heroes_initiative_wins_when_won_percentage = heroes_initiative_wins_match[2].to_f if heroes_initiative_wins_match[2]
        heroes_initiative_wins_when_won_count = heroes_initiative_wins_match[3].to_i if heroes_initiative_wins_match[3]
        heroes_wins_count_from_initiative = heroes_initiative_wins_match[4].to_i if heroes_initiative_wins_match[4]

        goblins_initiative_wins_when_won_percentage = goblins_initiative_wins_match[2].to_f if goblins_initiative_wins_match[2]
        goblins_initiative_wins_when_won_count = goblins_initiative_wins_match[3].to_i if goblins_initiative_wins_match[3]
        goblins_wins_count_from_initiative = goblins_initiative_wins_match[4].to_i if goblins_initiative_wins_match[4]

        assert_in_delta(heroes_wins_percentage, (heroes_wins_count.to_f / attempts * 100), 0.1)
        assert_in_delta(goblins_wins_percentage, (goblins_wins_count.to_f / attempts * 100), 0.1)

        if heroes_wins_count > 0
          assert_equal(heroes_wins_count, heroes_wins_count_from_initiative)
          assert_in_delta(heroes_initiative_wins_when_won_percentage, (heroes_initiative_wins_when_won_count.to_f / heroes_wins_count * 100), 0.1)
        else
          assert_nil(heroes_wins_count_from_initiative)
          assert_nil(heroes_initiative_wins_when_won_percentage)
        end

        if goblins_wins_count > 0
          assert_equal(goblins_wins_count, goblins_wins_count_from_initiative)
          assert_in_delta(goblins_initiative_wins_when_won_percentage, (goblins_initiative_wins_when_won_count.to_f / goblins_wins_count * 100), 0.1)
        else
          assert_nil(goblins_wins_count_from_initiative)
          assert_nil(goblins_initiative_wins_when_won_percentage)
        end
      end
    end
  end
end
