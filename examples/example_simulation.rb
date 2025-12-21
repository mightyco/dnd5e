require_relative "../lib/dnd5e/simulation/runner"
require_relative "../lib/dnd5e/simulation/scenario_builder"
require_relative "../lib/dnd5e/core/team_combat"
require_relative "../lib/dnd5e/core/character"
require_relative "../lib/dnd5e/core/monster"
require_relative "../lib/dnd5e/core/statblock"
require_relative "../lib/dnd5e/core/attack"
require_relative "../lib/dnd5e/core/dice"
require_relative "../lib/dnd5e/core/team"
require_relative "../lib/dnd5e/core/combat_statistics"
require_relative "../lib/dnd5e/simulation/scenario"
require_relative "../lib/dnd5e/builders"

require 'logger'

require_relative "../lib/dnd5e/core/combat_logger"

module Dnd5e
  module Examples
    class SimulationExample
      def self.run
        # Create a silent logger for the mass simulation
        silent_logger = Logger.new(nil)
        
        # Create a verbose logger for the sample
        verbose_logger = Logger.new($stdout)
        verbose_logger.formatter = proc do |severity, datetime, progname, msg|
          "#{msg}\n"
        end

        # Create a statistics collector (Observer)
        stats = Core::CombatStatistics.new

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

        # --- Run a Sample Battle (Verbose) ---
        puts "=== Example Combat Log ==="
        
        # We need deep copies for the sample so we don't affect the templates for simulation (though templates are reused via Builder usually)
        # Actually ScenarioBuilder creates new instances. 
        # For this sample, we'll manually create a one-off combat.
        
        # Create fresh combatants for the sample
        sample_hero1 = Core::Character.new(name: "Hero 1", statblock: hero_template.deep_copy, attacks: [sword_attack])
        sample_hero2 = Core::Character.new(name: "Hero 2", statblock: hero_template.deep_copy, attacks: [sword_attack])
        sample_goblin1 = Core::Monster.new(name: "Goblin 1", statblock: goblin_template.deep_copy, attacks: [bite_attack])
        sample_goblin2 = Core::Monster.new(name: "Goblin 2", statblock: goblin_template.deep_copy, attacks: [bite_attack])
        
        sample_heroes = Core::Team.new(name: "Heroes", members: [sample_hero1, sample_hero2])
        sample_goblins = Core::Team.new(name: "Goblins", members: [sample_goblin1, sample_goblin2])
        
        sample_combat = Core::TeamCombat.new(teams: [sample_heroes, sample_goblins], logger: verbose_logger)
        sample_combat.add_observer(Core::CombatLogger.new(verbose_logger))
        sample_combat.run_combat
        
        puts "=== End Example Log ===\n\n"

        # --- Run Simulation (Silent) ---
        puts "Running 1000 simulations..."

        # Create a scenario
        scenario = Simulation::ScenarioBuilder.new(num_simulations: 1000)
                                              .with_team(heroes)
                                              .with_team(goblins)
                                              .build

        # Create a simulation runner
        # Pass the stats observer as the result_handler
        runner = Simulation::Runner.new(
          scenario: scenario,
          result_handler: stats,
          logger: silent_logger
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
