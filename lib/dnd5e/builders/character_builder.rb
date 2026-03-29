# frozen_string_literal: true

require_relative 'spell_slot_calculator'
require_relative '../core/character'
require_relative '../core/statblock'
require_relative '../core/attack'
require_relative '../core/dice'
require_relative '../core/armor'
require_relative '../core/subclass_registry'

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
        @features = []
        @subclass_strategy = nil
        @strategy_override = nil
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

      def with_feature(feature)
        @features << feature
        self
      end

      # Applies the canonical features and strategy for a known subclass.
      # Call after as_fighter (or as_wizard etc.) so @statblock is available for level resolution.
      # Pass level: explicitly if calling before the class method, or if you need to override.
      def with_subclass(subclass, level: nil)
        resolved_level = level || @statblock&.level || 1
        Core::SubclassRegistry.features_for(subclass, resolved_level).each { |f| with_feature(f) }
        @subclass_strategy = Core::SubclassRegistry.strategy_for(subclass, resolved_level)
        self
      end

      # Explicitly sets a strategy, overriding any subclass default.
      def with_strategy(strategy)
        @strategy_override = strategy
        self
      end

      def as_fighter(level: 1, abilities: {}, armor_type: :heavy)
        abilities = merge_abilities(abilities)
        @statblock = build_fighter_statblock(level, abilities, armor_type)
        longsword = Core::Attack.new(name: 'Longsword', damage_dice: Core::Dice.new(1, 8), relevant_stat: :strength)
        with_attack(longsword) unless @attacks.any? { |a| a.name == 'Longsword' }
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

        opts = { attacks: @attacks, spells: @spells, features: @features }
        opts[:strategy] = @strategy_override || @subclass_strategy if @strategy_override || @subclass_strategy
        Core::Character.new(name: @name, statblock: @statblock, **opts)
      end

      private

      def merge_abilities(abilities)
        { strength: 10, dexterity: 10, constitution: 10, intelligence: 10, wisdom: 10, charisma: 10 }.merge(abilities)
      end

      def build_fighter_statblock(level, abilities, armor_type)
        Core::Statblock.new(
          name: @name, strength: abilities[:strength], dexterity: abilities[:dexterity],
          constitution: abilities[:constitution], intelligence: abilities[:intelligence],
          wisdom: abilities[:wisdom], charisma: abilities[:charisma], hit_die: 'd10',
          level: level, saving_throw_proficiencies: %i[strength constitution],
          equipped_armor: create_armor(armor_type), extra_attacks: (level >= 5 ? 1 : 0),
          resources: { action_surge: 1, second_wind: 1 }
        )
      end

      def create_armor(type)
        case type
        when :light
          Core::Armor.new(name: 'Studded Leather', base_ac: 12, type: :light, max_dex_bonus: 99)
        when :medium
          Core::Armor.new(name: 'Breastplate', base_ac: 14, type: :medium, max_dex_bonus: 2)
        else
          Core::Armor.new(name: 'Chain Mail', base_ac: 16, type: :heavy, max_dex_bonus: 0,
                          stealth_disadvantage: true)
        end
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
