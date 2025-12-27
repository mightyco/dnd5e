# frozen_string_literal: true

require_relative '../lib/dnd5e/experiments/experiment'
require_relative '../lib/dnd5e/builders/character_builder'
require_relative '../lib/dnd5e/core/team'
require_relative '../lib/dnd5e/core/attack'
require_relative '../lib/dnd5e/core/dice'

# Experiment: Does a Dexterity-based Fighter scale better than a Strength-based Fighter?
# We will test this across levels 1 to 5.
# We will also vary the number of combatants (1v1, 5v5).

Dnd5e::Experiments::Experiment.new(name: 'Fighter Scaling: Str vs Dex')
                              .independent_variable(:level, values: 1..5)
                              .independent_variable(:group_size, values: [1, 5])
                              .simulations_per_step(1000)
                              .control_group do |params|
  # Strength Fighter Team
  level = params[:level]
  size = params[:group_size]

  chars = (1..size).map do |i|
    Dnd5e::Builders::CharacterBuilder.new(name: "Str Fighter #{i}")
                                     .as_fighter(level: level, abilities: { strength: 16, dexterity: 10,
                                                                            constitution: 14 })
                                     .build.tap do |char|
      char.statblock.equipped_armor = nil # Naked combat
    end
  end
  Dnd5e::Core::Team.new(name: 'Strength Team', members: chars)
end
  .test_group do |params|
    # Dexterity Fighter Team
    level = params[:level]
    size = params[:group_size]

    chars = (1..size).map do |i|
      # Dex fighters use light armor (Leather) usually, but .as_fighter might default to chainmail/AC logic?
      # For now, we assume standard build.
      # Note: .as_fighter sets AC based on Dex.
      # Str Fighter: 10 Dex -> AC 10 (without armor logic updates)
      # Dex Fighter: 16 Dex -> AC 13
      # We need to ensure weapons use the right stat. .as_fighter adds Longsword (Str).
      # Dex fighter needs a Finesse weapon (Rapier).

      builder = Dnd5e::Builders::CharacterBuilder.new(name: "Dex Fighter #{i}")
                                                 .as_fighter(level: level, abilities: { strength: 10, dexterity: 16,
                                                                                        constitution: 14 })

      # Replace Longsword with Rapier for Dex build
      char = builder.build
      rapier = Dnd5e::Core::Attack.new(name: 'Rapier', damage_dice: Dnd5e::Core::Dice.new(1, 8),
                                       relevant_stat: :dexterity)
      char.attacks = [rapier]

      char.statblock.equipped_armor = nil # Naked combat

      char
    end
    Dnd5e::Core::Team.new(name: 'Dexterity Team', members: chars)
  end
  .run
