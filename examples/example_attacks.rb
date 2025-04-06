require_relative "../lib/dnd5e/core/attack"
require_relative "../lib/dnd5e/core/character"
require_relative "../lib/dnd5e/core/monster"
require_relative "../lib/dnd5e/core/statblock"
require_relative "../lib/dnd5e/core/dice"
require_relative "../lib/dnd5e/core/dice_roller"
require 'logger'

module Dnd5e
  module Core
    # Example of creating a character with attacks
    longsword_attack = Attack.new(name: "Longsword Slash", damage_dice: Dice.new(1, 8), relevant_stat: :strength)
    greatsword_attack = Attack.new(name: "Greatsword Slash", damage_dice: Dice.new(2, 6), relevant_stat: :strength)
    character_statblock = Statblock.new(name: "Hero", strength: 16, level: 3)
    hero = Character.new(name: "Aragorn", statblock: character_statblock, attacks: [longsword_attack, greatsword_attack])

    # Example of creating a monster with attacks
    goblin_statblock = Statblock.new(name: "Goblin Stats", strength: 8, dexterity: 14, constitution: 10, hit_die: "d6", level: 1)
    scimitar_attack = Attack.new(name: "Scimitar Slash", damage_dice: Dice.new(1, 6), relevant_stat: :strength)
    goblin = Monster.new(name: "Goblin", statblock: goblin_statblock, attacks: [scimitar_attack])

    # Example of using the attack
    silent_logger = Logger.new(nil)
    dice_roller = DiceRoller.new
    longsword_attack.instance_variable_set(:@logger, silent_logger)
    longsword_attack.instance_variable_set(:@dice_roller, dice_roller)
    scimitar_attack.instance_variable_set(:@logger, silent_logger)
    scimitar_attack.instance_variable_set(:@dice_roller, dice_roller)
    puts "Aragorn attacks Goblin"
    longsword_attack.attack(hero, goblin)
    puts "Goblin attacks Aragorn"
    scimitar_attack.attack(goblin, hero)
  end
end
