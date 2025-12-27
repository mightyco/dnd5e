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
      class << self
        def run
          setup
          resolve_attack
        end

        private

        def setup
          setup_services
          setup_combatants
        end

        def setup_services
          @logger = Logger.new($stdout)
          @logger.formatter = proc { |_sev, _dt, _prog, msg| "#{msg}\n" }
          @dice_roller = Core::DiceRoller.new
          @attack_resolver = Core::AttackResolver.new(logger: @logger)
        end

        def setup_combatants
          @hero = create_hero
          @goblin = create_goblin
        end

        def create_hero
          statblock = Core::Statblock.new(name: 'Hero', strength: 16, level: 3)
          attacks = [
            create_attack('Longsword', 1, 8, :strength),
            create_attack('Greatsword', 2, 6, :strength)
          ]
          Core::Character.new(name: 'Aragorn', statblock: statblock, attacks: attacks)
        end

        def create_goblin
          statblock = Core::Statblock.new(name: 'Goblin Stats', strength: 8, dexterity: 14, constitution: 10,
                                          hit_die: 'd6', level: 1)
          attack = create_attack('Scimitar Slash', 1, 6, :dexterity)
          Core::Monster.new(name: 'Goblin', statblock: statblock, attacks: [attack])
        end

        def create_attack(name, dice_count, dice_sides, stat)
          Core::Attack.new(name: name, damage_dice: Core::Dice.new(dice_count, dice_sides),
                           relevant_stat: stat, dice_roller: @dice_roller)
        end

        def resolve_attack
          @logger.info "Resolving attack between #{@hero.name} and #{@goblin.name}"
          @attack_resolver.resolve(@hero, @goblin, @hero.attacks.sample)
        end
      end
    end
  end
end

Dnd5e::Examples::AttacksExample.run
