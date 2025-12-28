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
require 'logger'

module Dnd5e
  module Simulation
    module RunnerTestSetup
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
        @hero1 = create_character('Hero1', @hero_statblock, @sword_attack)
        @hero2 = create_character('Hero2', @hero_statblock, @sword_attack)
        @goblin1 = create_monster('Goblin1', @goblin_statblock, @bite_attack)
        @goblin2 = create_monster('Goblin2', @goblin_statblock, @bite_attack)
      end

      def create_character(name, statblock, attack)
        Builders::CharacterBuilder.new(name: name)
                                  .with_statblock(statblock.deep_copy)
                                  .with_attack(attack)
                                  .build
      end

      def create_monster(name, statblock, attack)
        Builders::MonsterBuilder.new(name: name)
                                .with_statblock(statblock.deep_copy)
                                .with_attack(attack)
                                .build
      end

      def create_teams
        @heroes = Core::Team.new(name: 'Heroes', members: [@hero1, @hero2])
        @goblins = Core::Team.new(name: 'Goblins', members: [@goblin1, @goblin2])
      end
    end

    class TestRunner < Minitest::Test
      include RunnerTestSetup

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
        result_handler = SimulationCombatResultHandler.new
        scenario = ScenarioBuilder.new(num_simulations: attempts).with_team(@heroes).with_team(@goblins).build
        runner = Runner.new(scenario: scenario, result_handler: result_handler, logger: @logger)

        runner.run

        assert_equal attempts, result_handler.results.size
        winners = result_handler.results.map(&:winner).uniq

        assert_operator winners.size, :>=, 2, "Expected at least two different winners in #{attempts} simulations"
      end
    end
  end
end
