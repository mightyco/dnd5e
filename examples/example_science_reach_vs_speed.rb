# frozen_string_literal: true

require_relative '../lib/dnd5e/builders/character_builder'
require_relative '../lib/dnd5e/core/team'
require_relative '../lib/dnd5e/core/team_combat'
require_relative '../lib/dnd5e/simulation/runner'
require_relative '../lib/dnd5e/core/combat_statistics'

# Experiment: Reach vs Speed on Tactical Grid
# Objective: Determine if the 10ft reach of a heavy weapon (Pike) compensates for
#            lower speed when navigating a grid with difficult terrain.

module Dnd5e
  # Science experiments for the combat simulator.
  module Science
    # A specialized TeamCombat that sets up a tactical obstacle course.
    class ReachVsSpeedCombat < Core::TeamCombat
      def setup_stationary_grid(dist)
        # Place teams at (0,0) and (dist, 0)
        super

        # Add a "choke point" at the middle
        mid_x = (dist / 10).to_i * 5

        # Create a wall with a 1-square gap
        (-15..15).step(5).each do |y|
          next if y.zero? # The gap

          @grid.place('Wall Segment', Core::Point2D.new(mid_x, y))
        end

        # Set difficult terrain at the gap and surrounding squares
        @grid.set_terrain(Core::Point2D.new(mid_x, 0), :difficult)
        @grid.set_terrain(Core::Point2D.new(mid_x - 5, 0), :difficult)
        @grid.set_terrain(Core::Point2D.new(mid_x + 5, 0), :difficult)
      end
    end

    # A specialized Runner that uses our specialized Combat class.
    class ScienceRunner < Simulation::Runner
      def run_battle
        new_teams = create_teams
        scenario = ReachVsSpeedCombat.new(teams: new_teams, max_rounds: 100, distance: 60)
        scenario.add_observer(@result_handler) if @result_handler.respond_to?(:update)

        begin
          scenario.run_combat
        rescue Core::CombatTimeoutError => e
          @logger.warn "Combat timed out: #{e.message}"
        end

        return unless @result_handler.respond_to?(:results) && @result_handler.results.any?

        @results << @result_handler.results.last
      end
    end

    def self.run
      puts '=== Science Experiment: Reach vs Speed ==='
      puts 'Setting: 60ft corridor with a difficult terrain choke point at 30ft.'
      puts 'Control: Speed 30ft, Reach 5ft (Longsword)'
      puts 'Test:    Speed 25ft, Reach 10ft (Pike)'
      puts '-' * 40

      run_phase_one
      run_phase_two
    end

    def self.run_phase_one
      stats = Core::CombatStatistics.new
      control = build_control_fighter
      test = build_reach_fighter(25)

      scenario = build_scenario('Control', [control], 'Test', [test])
      runner = ScienceRunner.new(scenario: scenario, result_handler: stats)
      runner.run
      runner.generate_report
    end

    def self.run_phase_two
      puts "\n=== Experiment 2: Reach Advantage (Equal Speed) ==="
      puts 'Control: 30ft/5ft, Test: 30ft/10ft'
      puts '-' * 40

      stats = Core::CombatStatistics.new
      control = build_control_fighter
      test = build_reach_fighter(30)
      scenario = build_scenario('Control', [control], 'Test', [test])
      ScienceRunner.new(scenario: scenario, result_handler: stats).run
      puts stats.generate_report(100)
    end

    def self.build_control_fighter
      Builders::CharacterBuilder.new(name: 'Speedy (5ft Reach)')
                                .as_fighter(level: 1, abilities: { strength: 16, dexterity: 12,
                                                                   constitution: 14 })
                                .build
    end

    def self.build_reach_fighter(speed)
      fighter = Builders::CharacterBuilder.new(name: 'Reach (10ft Reach)')
                                          .as_fighter(level: 1,
                                                      abilities: { strength: 16, dexterity: 12,
                                                                   constitution: 14 })
                                          .build
      fighter.statblock.instance_variable_set(:@speed, speed)
      pike = Core::Attack.new(name: 'Pike', damage_dice: Core::Dice.new(1, 10), relevant_stat: :strength, range: 10)
      fighter.instance_variable_set(:@attacks, [pike])
      fighter
    end

    def self.build_scenario(name1, members1, name2, members2)
      Simulation::Scenario.new(
        teams: [
          Core::Team.new(name: name1, members: members1),
          Core::Team.new(name: name2, members: members2)
        ],
        num_simulations: 100
      )
    end
  end
end

Dnd5e::Science.run
