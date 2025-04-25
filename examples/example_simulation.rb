require_relative "../lib/dnd5e/simulation/runner"
require_relative "../lib/dnd5e/simulation/scenario_builder"
require_relative "../lib/dnd5e/core/team_combat"
require_relative "../lib/dnd5e/core/character"
require_relative "../lib/dnd5e/core/monster"
require_relative "../lib/dnd5e/core/statblock"
require_relative "../lib/dnd5e/core/attack"
require_relative "../lib/dnd5e/core/dice"
require_relative "../lib/dnd5e/core/team"
require_relative "../lib/dnd5e/simulation/simulation_combat_result_handler"
require_relative "../lib/dnd5e/core/printing_combat_result_handler"
require_relative "../lib/dnd5e/simulation/scenario"
require_relative "../lib/dnd5e/builders"

require 'logger'

module Dnd5e
  module Examples
    class SimulationExample
      def self.run
        # Create a logger that outputs to stdout
        logger = Logger.new($stdout)

        # Create a result handler
        result_handler = Simulation::SimulationCombatResultHandler.new(logger: logger)

        # Create some attacks
        sword_attack = Core::Attack.new(name: "Sword", damage_dice: Core::Dice.new(1, 8), relevant_stat: :strength)
        bite_attack = Core::Attack.new(name: "Bite", damage_dice: Core::Dice.new(1, 6), relevant_stat: :dexterity)

        # Create template statblocks
        hero_template = Core::Statblock.new(name: "Hero Template", strength: 16, dexterity: 10, constitution: 10, hit_die: "d10", level: 1)
        goblin_template = Core::Statblock.new(name: "Goblin Template", strength: 8, dexterity: 14, constitution: 10, hit_die: "d8", level: 1)

        # Create characters and monsters
        hero1 = Core::Character.new(name: "Hero 1", statblock: hero_template, attacks: [sword_attack])
        hero2 = Core::Character.new(name: "Hero 2", statblock: hero_template, attacks: [sword_attack])
        goblin1 = Core::Monster.new(name: "Goblin 1", statblock: goblin_template, attacks: [bite_attack])
        goblin2 = Core::Monster.new(name: "Goblin 2", statblock: goblin_template, attacks: [bite_attack])

        # Create teams
        heroes = Core::Team.new(name: "Heroes", members: [hero1, hero2])
        goblins = Core::Team.new(name: "Goblins", members: [goblin1, goblin2])

        # Create a scenario
        scenario = Simulation::ScenarioBuilder.new(num_simulations: 1000)
                                              .with_team(heroes)
                                              .with_team(goblins)
                                              .build

        # Create a simulation runner
        runner = Simulation::Runner.new(
          scenario: scenario,
          result_handler: result_handler,
          logger: logger
        )

        # Run the simulation
        runner.run

        # Generate the report
        runner.generate_report
      end
    end
  end
end

Dnd5e::Examples::SimulationExample.run
