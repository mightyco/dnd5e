# frozen_string_literal: true

require_relative '../lib/dnd5e/simulation/runner'
require_relative '../lib/dnd5e/simulation/scenario_builder'
require_relative '../lib/dnd5e/core/team_combat'
require_relative '../lib/dnd5e/core/character'
require_relative '../lib/dnd5e/core/monster'
require_relative '../lib/dnd5e/core/statblock'
require_relative '../lib/dnd5e/core/attack'
require_relative '../lib/dnd5e/core/dice'
require_relative '../lib/dnd5e/core/team'
require_relative '../lib/dnd5e/core/combat_statistics'
require_relative '../lib/dnd5e/simulation/scenario'
require_relative '../lib/dnd5e/builders'

require 'logger'

module Dnd5e
  module Examples
    # Example of running a full simulation.
    class SimulationExample
      def self.run
        new.run_simulation
      end

      def run_simulation
        logger = Logger.new($stdout)
        stats = Core::CombatStatistics.new
        scenario = create_scenario

        runner = Simulation::Runner.new(
          scenario: scenario,
          result_handler: stats,
          logger: logger
        )

        runner.run
        runner.generate_report
      end

      private

      def create_scenario
        heroes = create_hero_team
        goblins = create_goblin_team

        Simulation::ScenarioBuilder.new(num_simulations: 1000)
                                   .with_team(heroes)
                                   .with_team(goblins)
                                   .build
      end

      def create_hero_team
        sword_attack = Core::Attack.new(name: 'Sword', damage_dice: Core::Dice.new(1, 8), relevant_stat: :strength)
        hero_template = Core::Statblock.new(name: 'Hero Template', strength: 16, dexterity: 10, constitution: 10,
                                            hit_die: 'd10', level: 1)

        hero1 = Core::Character.new(name: 'Hero 1', statblock: hero_template, attacks: [sword_attack])
        hero2 = Core::Character.new(name: 'Hero 2', statblock: hero_template, attacks: [sword_attack])

        Core::Team.new(name: 'Heroes', members: [hero1, hero2])
      end

      def create_goblin_team
        bite_attack = Core::Attack.new(name: 'Bite', damage_dice: Core::Dice.new(1, 6), relevant_stat: :dexterity)
        goblin_template = Core::Statblock.new(name: 'Goblin Template', strength: 8, dexterity: 14, constitution: 10,
                                              hit_die: 'd8', level: 1)

        goblin1 = Core::Monster.new(name: 'Goblin 1', statblock: goblin_template, attacks: [bite_attack])
        goblin2 = Core::Monster.new(name: 'Goblin 2', statblock: goblin_template, attacks: [bite_attack])

        Core::Team.new(name: 'Goblins', members: [goblin1, goblin2])
      end
    end
  end
end

Dnd5e::Examples::SimulationExample.run
