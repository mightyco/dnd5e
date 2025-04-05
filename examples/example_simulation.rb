require_relative "../lib/dnd5e/simulation/runner"
require_relative "../lib/dnd5e/core/team_combat"
require_relative "../lib/dnd5e/core/character"
require_relative "../lib/dnd5e/core/monster"
require_relative "../lib/dnd5e/core/statblock"
require_relative "../lib/dnd5e/core/attack"
require_relative "../lib/dnd5e/core/dice"
require_relative "../lib/dnd5e/core/team"
require_relative "../lib/dnd5e/simulation/simulation_combat_result_handler"
require_relative "../lib/dnd5e/simulation/mock_battle_scenario"

module Dnd5e
  module Core
    # Create some attacks
    sword_attack = Attack.new(name: "Sword", damage_dice: Dice.new(1, 8), relevant_stat: :strength)
    bite_attack = Attack.new(name: "Bite", damage_dice: Dice.new(1, 6), relevant_stat: :dexterity)

    # Create template statblocks
    hero_template = Statblock.new(name: "Hero Template", strength: 16, dexterity: 10, constitution: 15, hit_die: "d10", level: 3)
    goblin_template = Statblock.new(name: "Goblin Template", strength: 8, dexterity: 16, constitution: 10, hit_die: "d6", level: 1)

    # Create characters and monsters using deep copy
    hero1 = Character.new(name: "Hero 1", statblock: hero_template.deep_copy, attacks: [sword_attack])
    hero2 = Character.new(name: "Hero 2", statblock: hero_template.deep_copy, attacks: [sword_attack])
    goblin1 = Monster.new(name: "Goblin 1", statblock: goblin_template.deep_copy, attacks: [bite_attack])
    goblin2 = Monster.new(name: "Goblin 2", statblock: goblin_template.deep_copy, attacks: [bite_attack])

    # Create teams
    heroes = Team.new(name: "Heroes", members: [hero1, hero2])
    goblins = Team.new(name: "Goblins", members: [goblin1, goblin2])
    TEAMS = [heroes, goblins]

    # Create a result handler
    RESULT_HANDLER = Simulation::SimulationCombatResultHandler.new
  end
end

# Create a simulation runner
runner = Dnd5e::Simulation::Runner.new(
  Dnd5e::Simulation::MockBattleScenario,
  num_simulations: 1000,
  result_handler: Dnd5e::Core::RESULT_HANDLER,
  teams: Dnd5e::Core::TEAMS
)

# Run the simulation
runner.run

# Generate the report
runner.generate_report
