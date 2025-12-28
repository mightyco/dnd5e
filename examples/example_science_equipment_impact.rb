# frozen_string_literal: true

require_relative '../lib/dnd5e/experiments/experiment'
require_relative '../lib/dnd5e/builders/character_builder'
require_relative '../lib/dnd5e/core/team'
require_relative '../lib/dnd5e/core/attack'
require_relative '../lib/dnd5e/core/dice'
require_relative '../lib/dnd5e/core/armor'

module Dnd5e
  module Examples
    # Experiment: Strength (Heavy Armor) vs Dexterity (Light Armor)
    # Hypothesis: Strength should have a slight advantage at Level 1 due to AC 16 vs AC 15.
    # However, Dex Initiative might still tip the scales.
    class EquipmentImpact
      def self.run
        Experiments::Experiment.new(name: 'Equipment Impact: Plate vs Leather')
                               .independent_variable(:level, values: 1..10)
                               .simulations_per_step(500)
                               .control_group { |params| create_str_team(params) }
                               .test_group { |params| create_dex_team(params) }
                               .run
      end

      def self.create_str_team(params)
        char = create_character('Str Knight', params[:level], { strength: 16, dexterity: 10, constitution: 14 })
        chain_mail = Core::Armor.new(name: 'Chain Mail', base_ac: 16, type: :heavy, max_dex_bonus: 0,
                                     stealth_disadvantage: true)
        char.statblock.equipped_armor = chain_mail
        Core::Team.new(name: 'Str Team', members: [char])
      end

      def self.create_dex_team(params)
        char = create_character('Dex Duelist', params[:level], { strength: 10, dexterity: 16, constitution: 14 })
        studded_leather = Core::Armor.new(name: 'Studded Leather', base_ac: 12, type: :light, max_dex_bonus: nil,
                                          stealth_disadvantage: false)
        char.statblock.equipped_armor = studded_leather
        equip_rapier(char)
        Core::Team.new(name: 'Dex Team', members: [char])
      end

      def self.create_character(name, level, abilities)
        Builders::CharacterBuilder.new(name: name)
                                  .as_fighter(level: level, abilities: abilities)
                                  .build
      end

      def self.equip_rapier(character)
        rapier = Core::Attack.new(name: 'Rapier', damage_dice: Core::Dice.new(1, 8), relevant_stat: :dexterity)
        character.attacks = [rapier]
      end
    end
  end
end

Dnd5e::Examples::EquipmentImpact.run
