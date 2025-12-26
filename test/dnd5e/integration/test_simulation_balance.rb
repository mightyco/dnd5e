require_relative "../../test_helper"
require_relative "../../../lib/dnd5e/core/team_combat"
require_relative "../../../lib/dnd5e/builders/team_builder"
require_relative "../../../lib/dnd5e/builders/character_builder"
require_relative "../../../lib/dnd5e/core/attack"
require_relative "../../../lib/dnd5e/core/dice"
require_relative "../../../lib/dnd5e/simulation/runner"
require_relative "../../../lib/dnd5e/simulation/silent_combat_result_handler"
require_relative "../../../lib/dnd5e/simulation/scenario_builder"

module Dnd5e
  module Integration
    class TestSimulationBalance < Minitest::Test
      def setup
        @dice_roller = Core::DiceRoller.new
      end

      def test_balanced_combat_win_rates
        # Setup two identical teams
        # 10 vs 10 identical stats should be roughly 50/50
        
        statblock = Core::Statblock.new(
          name: "Soldier",
          strength: 14,
          dexterity: 14,
          constitution: 14,
          hit_die: "d8",
          level: 1
        )
        
        sword = Core::Attack.new(
          name: "Sword",
          damage_dice: Core::Dice.new(1, 8),
          relevant_stat: :strength
        )

        # Team A
        team_a_chars = (1..5).map do |i|
          Builders::CharacterBuilder.new(name: "A#{i}")
                                   .with_statblock(statblock.deep_copy)
                                   .with_attack(sword)
                                   .build
        end
        team_a = Core::Team.new(name: "Team A", members: team_a_chars)

        # Team B
        team_b_chars = (1..5).map do |i|
          Builders::CharacterBuilder.new(name: "B#{i}")
                                   .with_statblock(statblock.deep_copy)
                                   .with_attack(sword)
                                   .build
        end
        team_b = Core::Team.new(name: "Team B", members: team_b_chars)

        scenario = Core::TeamCombat.new(teams: [team_a, team_b])
        handler = Simulation::SilentCombatResultHandler.new
        
        # Run 500 simulations
        runner = Simulation::Runner.new(scenario: scenario, result_handler: handler)
        # Monkey patch num_simulations for this test or just run loop
        # Runner uses @scenario.num_simulations. 
        # ScenarioBuilder usually sets this. We manually built TeamCombat which is a Combat, not Scenario.
        # But Runner expects a Scenario object which responds to num_simulations.
        # Wait, Runner takes a `scenario` which is expected to be a Scenario object from ScenarioBuilder?
        # Let's check Runner usage.
        
        # In example_simulation.rb:
        # scenario = Dnd5e::Simulation::ScenarioBuilder.new ... .build
        # runner = Simulation::Runner.new(scenario: scenario ... )
        
        # We should use ScenarioBuilder to be consistent.
        
        builder = Simulation::ScenarioBuilder.new(num_simulations: 1000)
        builder.with_team(team_a)
        builder.with_team(team_b)
        scenario_obj = builder.build
        
        runner = Simulation::Runner.new(scenario: scenario_obj, result_handler: handler)
        
        # Capture stdout to silence report
        runner.run
        
        # Analyze results
        wins_a = handler.results.count { |r| r.winner.name == "Team A" }
        wins_b = handler.results.count { |r| r.winner.name == "Team B" }
        
        # Assert within reasonable variance (e.g. +/- 3 Standard Deviations)
        # Based on variance analysis: Mean ~500, StdDev ~16.5
        # Range: 450 - 550 covers >99.7% of cases.
        
        assert_operator wins_a, :>=, 450, "Team A wins (#{wins_a}) too low for balanced combat"
        assert_operator wins_a, :<=, 550, "Team A wins (#{wins_a}) too high for balanced combat"
      end
    end
  end
end
