require_relative "../lib/dnd5e/core/combat"
require_relative "../lib/dnd5e/core/character"
require_relative "../lib/dnd5e/core/monster"
require_relative "../lib/dnd5e/core/statblock"
require_relative "../lib/dnd5e/core/attack"
require_relative "../lib/dnd5e/core/dice"

module Dnd5e
  module Core
    # Create some attacks
    sword_attack = Attack.new(name: "Sword", damage_dice: Dice.new(1, 8), relevant_stat: :strength)
    bite_attack = Attack.new(name: "Bite", damage_dice: Dice.new(1, 6), relevant_stat: :strength)

    # Create some statblocks
    hero_statblock = Statblock.new(name: "Hero Statblock", strength: 16, dexterity: 14, constitution: 15, hit_die: "d10", level: 3)
    goblin_statblock = Statblock.new(name: "Goblin Statblock", strength: 8, dexterity: 14, constitution: 10, hit_die: "d6", level: 1)

    # Create some characters and monsters
    hero = Character.new(name: "Hero", statblock: hero_statblock, attacks: [sword_attack])
    goblin1 = Monster.new(name: "Goblin 1", statblock: goblin_statblock, attacks: [bite_attack])
    goblin2 = Monster.new(name: "Goblin 2", statblock: goblin_statblock, attacks: [bite_attack])

    # Create teams
    heroes = Team.new(name: "Heroes", members: [hero])
    goblins = Team.new(name: "Goblins", members: [goblin1, goblin2])

    # Create combat
    combat = Combat.new(teams: [heroes, goblins])

    # Start the battle
    combat.start
  end
end
