# frozen_string_literal: true

require_relative 'spell_slot_calculator'
require_relative '../core/character'
require_relative '../core/statblock'
require_relative '../core/attack'
require_relative '../core/dice'
require_relative '../core/armor'

module Dnd5e
  module Builders
    # Builds a Character object with a fluent interface.
    class CharacterBuilder
      class InvalidCharacterError < StandardError; end

      def initialize(name:)
        @name = name
        @statblock = nil
        @attacks = []
        @spells = []
      end

      def with_statblock(statblock)
        @statblock = statblock
        self
      end

      def with_attack(attack)
        @attacks << attack
        self
      end

      def with_spell(spell)
        @spells << spell
        self
      end

      def as_fighter(level: 1, abilities: {})
        abilities = merge_abilities(abilities)
        @statblock = build_fighter_statblock(level, abilities)
        add_fighter_equipment
        self
      end

      def as_wizard(level: 1, abilities: {})
        abilities = merge_abilities(abilities)
        @statblock = build_wizard_statblock(level, abilities)
        add_wizard_equipment
        self
      end

      def build
        raise InvalidCharacterError, 'Character must have a name' if @name.nil? || @name.empty?
        raise InvalidCharacterError, 'Character must have a statblock' if @statblock.nil?

        Core::Character.new(name: @name, statblock: @statblock, attacks: @attacks, spells: @spells)
      end

      private

      def merge_abilities(abilities)
        { strength: 10, dexterity: 10, constitution: 10, intelligence: 10, wisdom: 10, charisma: 10 }.merge(abilities)
      end

      def build_fighter_statblock(level, abilities)
        chain_mail = Core::Armor.new(name: 'Chain Mail', base_ac: 16, type: :heavy, max_dex_bonus: 0,
                                     stealth_disadvantage: true)
        extra_attacks = level >= 5 ? 1 : 0
        resources = { action_surge: 1, second_wind: 1 }
        create_fighter_statblock(level, abilities, chain_mail, extra_attacks, resources)
      end

      def create_fighter_statblock(level, abilities, armor, extra, resources)
        Core::Statblock.new(
          name: @name, strength: abilities[:strength], dexterity: abilities[:dexterity],
          constitution: abilities[:constitution], intelligence: abilities[:intelligence],
          wisdom: abilities[:wisdom], charisma: abilities[:charisma], hit_die: 'd10',
          level: level, saving_throw_proficiencies: %i[strength constitution],
          equipped_armor: armor, extra_attacks: extra, resources: resources
        )
      end

      def add_fighter_equipment
        return if @attacks.any? { |a| a.name == 'Longsword' }

        longsword = Core::Attack.new(name: 'Longsword', damage_dice: Core::Dice.new(1, 8), relevant_stat: :strength)
        with_attack(longsword)
      end

      def build_wizard_statblock(level, abilities)
        resources = SpellSlotCalculator.calculate('Wizard', level)
        Core::Statblock.new(
          name: @name,
          strength: abilities[:strength], dexterity: abilities[:dexterity], constitution: abilities[:constitution],
          intelligence: abilities[:intelligence], wisdom: abilities[:wisdom], charisma: abilities[:charisma],
          hit_die: 'd6', level: level, saving_throw_proficiencies: %i[intelligence wisdom],
          resources: resources
        )
      end

      def add_wizard_equipment
        firebolt = Core::Attack.new(name: 'Firebolt', damage_dice: Core::Dice.new(1, 10), relevant_stat: :intelligence,
                                    type: :attack, scaling: true, range: 120)
        with_attack(firebolt)

        return if @attacks.any? { |a| a.name == 'Quarterstaff' }

        staff = Core::Attack.new(name: 'Quarterstaff', damage_dice: Core::Dice.new(1, 6), relevant_stat: :strength)
        with_attack(staff)
      end
    end
  end
end
