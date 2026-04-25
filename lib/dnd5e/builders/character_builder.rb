# frozen_string_literal: true

require_relative 'spell_slot_calculator'
require_relative 'character_build_logic'
require_relative '../core/character'
require_relative '../core/statblock'
require_relative '../core/attack'
require_relative '../core/dice'
require_relative '../core/armor'
require_relative '../core/subclass_registry'
require_relative '../core/feat_registry'
require_relative '../core/features/sneak_attack'
require_relative '../core/features/cunning_action'
require_relative '../core/features/evasion'
require_relative '../core/features/action_surge'
require_relative '../core/features/second_wind'
require_relative '../core/strategies/rogue_strategy'

module Dnd5e
  module Builders
    # Helper for creating equipment in CharacterBuilder
    module EquipmentHelper
      private

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

      def add_wizard_equipment
        firebolt = Core::Attack.new(name: 'Firebolt', damage_dice: Core::Dice.new(1, 10), relevant_stat: :intelligence,
                                    type: :attack, scaling: true, range: 120)
        with_attack(firebolt)
        return if @attacks.any? { |a| a.name == 'Quarterstaff' }

        staff = Core::Attack.new(name: 'Quarterstaff', damage_dice: Core::Dice.new(1, 6), relevant_stat: :strength)
        with_attack(staff)
      end
    end

    # Builds a Character object with a fluent interface.
    class CharacterBuilder
      include EquipmentHelper
      include ClassBuildLogic

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

      def with_feat(feat_key)
        @features << Core::FeatRegistry.create(feat_key)
        self
      end

      def with_subclass(subclass, level: nil)
        resolved_level = level || @statblock&.level || 1
        Core::SubclassRegistry.features_for(subclass, resolved_level).each { |f| with_feature(f) }
        @subclass_strategy = Core::SubclassRegistry.strategy_for(subclass, resolved_level)
        self
      end

      def with_strategy(strategy)
        @strategy_override = strategy
        self
      end

      def as_rogue(level: 1, abilities: {})
        abilities = merge_abilities(abilities)
        @statblock = build_rogue_statblock(level, abilities)
        add_rogue_equipment
        add_rogue_features(level)
        self
      end

      def as_fighter(level: 1, abilities: {}, armor_type: :heavy)
        abilities = merge_abilities(abilities)
        @statblock = build_fighter_statblock(level, abilities, armor_type)
        longsword = Core::Attack.new(name: 'Longsword', damage_dice: Core::Dice.new(1, 8), relevant_stat: :strength)
        with_attack(longsword) unless @attacks.any? { |a| a.name == 'Longsword' }

        with_feature(Core::Features::ActionSurge.new) if level >= 2
        with_feature(Core::Features::SecondWind.new) if level >= 1
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
    end
  end
end
