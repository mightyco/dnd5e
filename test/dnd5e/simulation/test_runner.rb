# frozen_string_literal: true

require_relative '../../test_helper'
require_relative '../../../lib/dnd5e/simulation/runner'
require_relative '../../../lib/dnd5e/simulation/silent_combat_result_handler'
require_relative '../../../lib/dnd5e/simulation/simulation_combat_result_handler'
require_relative '../../../lib/dnd5e/core/team'
require_relative '../../../lib/dnd5e/simulation/scenario'
require_relative '../../../lib/dnd5e/simulation/scenario_builder'
require_relative '../../../lib/dnd5e/builders/character_builder'
require_relative '../../../lib/dnd5e/builders/monster_builder'
require_relative '../../../lib/dnd5e/core/statblock'
require_relative '../../../lib/dnd5e/core/attack'
require_relative '../../../lib/dnd5e/core/dice'

require 'logger'

module Dnd5e
  module Simulation
    class TestRunner < Minitest::Test
      def setup
        create_statblocks
        create_attacks
        create_combatants
        create_teams
        @scenario = ScenarioBuilder.new(num_simulations: 1000).with_team(@heroes).with_team(@goblins).build
        @logger = Logger.new(nil)
      end

      def create_statblocks
        @hero_statblock = Core::Statblock.new(name: 'Hero Statblock', strength: 16, dexterity: 10, constitution: 15,
                                              hit_die: 'd10', level: 3)
        @goblin_statblock = Core::Statblock.new(name: 'Goblin Statblock', strength: 8, dexterity: 14, constitution: 10,
                                                hit_die: 'd6', level: 1)
      end

      def create_attacks
        @sword_attack = Core::Attack.new(name: 'Sword', damage_dice: Core::Dice.new(1, 8), relevant_stat: :strength)
        @bite_attack = Core::Attack.new(name: 'Bite', damage_dice: Core::Dice.new(1, 6), relevant_stat: :dexterity)
      end

      def create_combatants
        @hero1 = Builders::CharacterBuilder.new(name: 'Hero1')
                                           .with_statblock(@hero_statblock.deep_copy)
                                           .with_attack(@sword_attack)
                                           .build
        @hero2 = Builders::CharacterBuilder.new(name: 'Hero2')
                                           .with_statblock(@hero_statblock.deep_copy)
                                           .with_attack(@sword_attack)
                                           .build
        @goblin1 = Builders::MonsterBuilder.new(name: 'Goblin1')
                                           .with_statblock(@goblin_statblock.deep_copy)
                                           .with_attack(@bite_attack)
                                           .build
        @goblin2 = Builders::MonsterBuilder.new(name: 'Goblin2')
                                           .with_statblock(@goblin_statblock.deep_copy)
                                           .with_attack(@bite_attack)
                                           .build
      end

      def create_teams
        @heroes = Core::Team.new(name: 'Heroes', members: [@hero1, @hero2])
        @goblins = Core::Team.new(name: 'Goblins', members: [@goblin1, @goblin2])
      end

      def test_runner_initialization
        runner = Runner.new(scenario: @scenario, result_handler: SilentCombatResultHandler.new, logger: @logger)
        assert_equal 1000, runner.scenario.num_simulations
        assert_empty runner.results
      end

      def test_run_battle
        scenario = ScenarioBuilder.new(num_simulations: 1).with_team(@heroes).with_team(@goblins).build
        result_handler = SilentCombatResultHandler.new
        runner = Runner.new(scenario: scenario, result_handler: result_handler, logger: @logger)
        runner.run_battle
        assert_equal 1, runner.results.size
        assert_instance_of Result, runner.results.first
      end

      def test_run
        scenario = ScenarioBuilder.new(num_simulations: 5).with_team(@heroes).with_team(@goblins).build
        result_handler = SilentCombatResultHandler.new
        runner = Runner.new(scenario: scenario, result_handler: result_handler, logger: @logger)
        runner.run
        assert_equal 5, runner.results.size
        runner.results.each do |result|
          assert_instance_of Result, result
        end
      end

      def test_generate_report
        scenario = ScenarioBuilder.new(num_simulations: 5).with_team(@heroes).with_team(@goblins).build
        result_handler = SimulationCombatResultHandler.new
        runner = Runner.new(scenario: scenario, result_handler: result_handler, logger: @logger)
        runner.run
        assert_output(/Simulation Report/) { runner.generate_report }
      end

      def test_simulation_resets_between_runs
        attempts = 100
        # Create a new result handler for this test
        result_handler = SimulationCombatResultHandler.new

        # Create a new runner for this test
        scenario = ScenarioBuilder.new(num_simulations: attempts).with_team(@heroes).with_team(@goblins).build
        runner = Runner.new(
          scenario: scenario,
          result_handler: result_handler,
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
        scenario = ScenarioBuilder.new(num_simulations: attempts).with_team(@heroes).with_team(@goblins).build
        runner = Runner.new(scenario: scenario, result_handler: result_handler, logger: @logger)
        runner.run
        report = result_handler.report(attempts)

        verify_report_structure(report, attempts)
        verify_report_numbers(report, attempts)
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

      def parse_team_data(report, team_name, attempts)
        wins_match = report.match(/#{team_name} won (\d+\.\d+)% \((\d+) of #{attempts}\) of the battles/)
        init_match = report.match(/#{team_name} won initiative (\d+\.\d+)% \(\d+ of #{attempts}\) of the time overall(?: but (\d+\.\d+)% of the time that they won the battle \((\d+) of (\d+)\))?/)

        {
          wins_pct: wins_match[1].to_f,
          wins_count: wins_match[2].to_i,
          init_won_when_won_pct: init_match[2]&.to_f,
          init_won_when_won_count: init_match[3]&.to_i,
          wins_count_from_init: init_match[4]&.to_i
        }
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
