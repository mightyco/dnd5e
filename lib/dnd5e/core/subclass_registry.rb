# frozen_string_literal: true

require_relative 'features/battle_master'
require_relative 'features/improved_critical'
require_relative 'features/wizard_evoker'
require_relative 'features/wizard_abjurer'
require_relative 'features/wizard_diviner'
require_relative 'features/barbarian_berserker'
require_relative 'features/barbarian_wild_heart'
require_relative 'features/barbarian_zealot'
require_relative 'features/paladin_features'
require_relative 'features/ranger_features'
require_relative 'features/cleric_features'
require_relative 'features/cleric_light'
require_relative 'features/bard_features'
require_relative 'features/bard_valor'
require_relative 'features/druid_features'
require_relative 'features/druid_moon'
require_relative 'features/sorcerer_features'
require_relative 'features/warlock_features'
require_relative 'features/rogue_assassin'
require_relative 'features/rogue_thief'
require_relative 'features/monk_open_hand'
require_relative 'features/monk_elements'
require_relative 'features/monk_shadow'
require_relative 'features/fighter_eldritch_knight'
require_relative 'features/bard_lore'
require_relative 'features/bard_glamour'
require_relative 'features/cleric_trickery'
require_relative 'features/druid_land'
require_relative 'features/druid_sea'
require_relative 'features/paladin_vengeance'
require_relative 'features/paladin_glory'
require_relative 'features/ranger_beast_master'
require_relative 'features/ranger_fey_wanderer'
require_relative 'features/sorcerer_wild_magic'
require_relative 'features/sorcerer_aberrant'
require_relative 'features/warlock_archfey'
require_relative 'features/warlock_goo'
require_relative 'strategies/battle_master_strategy'
require_relative 'strategies/barbarian_strategy'
require_relative 'strategies/paladin_strategy'
require_relative 'strategies/monk_strategy'
require_relative 'strategies/ranger_strategy'
require_relative 'strategies/cleric_strategy'
require_relative 'strategies/bard_strategy'
require_relative 'strategies/druid_strategy'
require_relative 'strategies/sorcerer_strategy'
require_relative 'strategies/warlock_strategy'
require_relative 'strategies/rogue_strategy'
require_relative 'strategies/simple_strategy'
require_relative 'subclasses/martial_subclasses'
require_relative 'subclasses/caster_subclasses'
require_relative 'subclasses/hybrid_subclasses'

module Dnd5e
  module Core
    # Maps class subclasses to their canonical features and strategy.
    class SubclassRegistry
      SUBCLASSES = {}.merge(Subclasses::MARTIAL_SUBCLASSES)
                     .merge(Subclasses::CASTER_SUBCLASSES)
                     .merge(Subclasses::HYBRID_SUBCLASSES)
                     .freeze

      def self.features_for(subclass, level)
        entry = fetch(subclass)
        entry[:features].call(level)
      end

      def self.strategy_for(subclass, level)
        entry = fetch(subclass)
        entry[:strategy].call(level)
      end

      def self.subclasses_for(class_name)
        SUBCLASSES.select { |_k, v| v[:class] == class_name.to_sym }.keys.map(&:to_s)
      end

      def self.all_by_class
        SUBCLASSES.each_with_object({}) do |(k, v), hash|
          hash[v[:class]] ||= []
          hash[v[:class]] << k.to_s
        end
      end

      def self.known?(subclass)
        SUBCLASSES.key?(subclass.to_sym)
      end

      def self.fetch(subclass)
        SUBCLASSES.fetch(subclass.to_sym) do
          raise ArgumentError, "Unknown subclass: #{subclass}. Known: #{SUBCLASSES.keys.join(', ')}"
        end
      end
      private_class_method :fetch
    end
  end
end
