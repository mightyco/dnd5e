# frozen_string_literal: true

require_relative '../lib/dnd5e/builders/character_builder'
require_relative '../lib/dnd5e/builders/monster_builder'
require_relative '../lib/dnd5e/core/team'
require_relative '../lib/dnd5e/core/dice'
require_relative '../lib/dnd5e/core/attack'
require_relative '../lib/dnd5e/core/statblock'
require_relative '../lib/dnd5e/experiments/experiment'

# This experiment compares a STR-based Fighter vs a DEX-based Fighter.
# We strip armor to simulate "naked" combat, highlighting the raw impact of
# Dexterity (AC + Init + Atk/Dmg) vs Strength (Atk/Dmg only).
experiment = Dnd5e::Experiments::Experiment.new(name: 'STR vs DEX Fighter (Naked)')
                                           .simulations_per_step(1000)
                                           .independent_variable(:level, values: 1..10)

experiment.control_group do |params|
  level = params[:level]
  str_fighter = Dnd5e::Builders::CharacterBuilder.new(name: 'STR Fighter')
                                                 .as_fighter(level: level, abilities: { strength: 16, dexterity: 10,
                                                                                        constitution: 14 })
                                                 .build
  # Remove Armor to test raw stats
  str_fighter.statblock.equipped_armor = nil
  str_fighter.statblock.equipped_shield = nil

  Dnd5e::Core::Team.new(name: 'STR Team', members: [str_fighter])
end

experiment.test_group do |params|
  level = params[:level]
  dex_fighter = Dnd5e::Builders::CharacterBuilder.new(name: 'DEX Fighter')
                                                 .as_fighter(level: level, abilities: { strength: 10, dexterity: 16,
                                                                                        constitution: 14 })
                                                 .build
  # Override attack to use DEX (finesse)
  dex_attack = Dnd5e::Core::Attack.new(name: 'Rapier', damage_dice: Dnd5e::Core::Dice.new(1, 8),
                                       relevant_stat: :dexterity)
  dex_fighter.attacks = [dex_attack]

  # Remove Armor to test raw stats
  dex_fighter.statblock.equipped_armor = nil
  dex_fighter.statblock.equipped_shield = nil

  Dnd5e::Core::Team.new(name: 'DEX Team', members: [dex_fighter])
end

experiment.run
