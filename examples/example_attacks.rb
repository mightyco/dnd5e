# frozen_string_literal: true

require_relative '../lib/dnd5e/core/attack'
require_relative '../lib/dnd5e/core/character'
require_relative '../lib/dnd5e/core/monster'
require_relative '../lib/dnd5e/core/statblock'
require_relative '../lib/dnd5e/core/dice'
require_relative '../lib/dnd5e/core/dice_roller'
require_relative '../lib/dnd5e/core/attack_resolver'
require 'logger'

module Dnd5e
  module Examples
    # Demonstrates creating characters and monsters with attacks, and resolving an attack.
    class AttacksExample
      def self.run
        logger = Logger.new($stdout)
        logger.formatter = proc do |_severity, _datetime, _progname, msg|
          "#{msg}\n"
        end
        dice_roller = Core::DiceRoller.new
        attack_resolver = Core::AttackResolver.new(logger: logger)

        # Create attacks
        longsword_attack = Core::Attack.new(name: 'Longsword Slash', damage_dice: Core::Dice.new(1, 8),
                                            relevant_stat: :strength, dice_roller: dice_roller)
        greatsword_attack = Core::Attack.new(name: 'Greatsword Slash', damage_dice: Core::Dice.new(2, 6),
                                             relevant_stat: :strength, dice_roller: dice_roller)
        scimitar_attack = Core::Attack.new(name: 'Scimitar Slash', damage_dice: Core::Dice.new(1, 6),
                                           relevant_stat: :dexterity, dice_roller: dice_roller)

        # Create character
        character_statblock = Core::Statblock.new(name: 'Hero', strength: 16, level: 3)
        hero = Core::Character.new(name: 'Aragorn', statblock: character_statblock,
                                   attacks: [longsword_attack, greatsword_attack])

        # Create monster
        goblin_statblock = Core::Statblock.new(name: 'Goblin Stats', strength: 8, dexterity: 14, constitution: 10,
                                               hit_die: 'd6', level: 1)
        goblin = Core::Monster.new(name: 'Goblin', statblock: goblin_statblock, attacks: [scimitar_attack])

        # Resolve an attack
        logger.info "Resolving attack between #{hero.name} and #{goblin.name}"
        attack_resolver.resolve(hero, goblin, hero.attacks.sample)
      end
    end
  end
end

Dnd5e::Examples::AttacksExample.run
