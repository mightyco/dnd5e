# frozen_string_literal: true

require_relative 'features/battle_master'
require_relative 'features/improved_critical'
require_relative 'features/wizard_evoker'
require_relative 'features/wizard_abjurer'
require_relative 'features/barbarian_berserker'
require_relative 'features/paladin_features'
require_relative 'features/ranger_features'
require_relative 'features/cleric_features'
require_relative 'features/bard_features'
require_relative 'features/druid_features'
require_relative 'features/sorcerer_features'
require_relative 'features/warlock_features'
require_relative 'features/rogue_assassin'
require_relative 'features/monk_open_hand'
require_relative 'features/bard_valor'
require_relative 'features/druid_moon'
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

module Dnd5e
  module Core
    # Maps fighter (and future class) subclasses to their canonical features and strategy.
    # This is the single source of truth for "what does a battlemaster get?".
    class SubclassRegistry
      SUBCLASSES = {
        battlemaster: {
          class: :fighter,
          features: ->(level) { [Features::BattleMaster.new(level: level)] },
          strategy: ->(_level) { Strategies::BattleMasterStrategy.new }
        },
        champion: {
          class: :fighter,
          features: ->(_level) { [Features::ImprovedCritical.new] },
          strategy: ->(_level) { Strategies::SimpleStrategy.new }
        },
        evoker: {
          class: :wizard,
          features: ->(_level) { [Features::SculptSpells.new, Features::EmpoweredEvocation.new] },
          strategy: ->(_level) { Strategies::SimpleStrategy.new }
        },
        abjurer: {
          class: :wizard,
          features: ->(level) { [Features::ArcaneWard.new(level: level)] },
          strategy: ->(_level) { Strategies::SimpleStrategy.new }
        },
        berserker: {
          class: :barbarian,
          features: ->(_level) { [Features::Frenzy.new] },
          strategy: ->(_level) { Strategies::BarbarianStrategy.new }
        },
        devotion: {
          class: :paladin,
          features: ->(_level) { [Features::SacredWeapon.new] },
          strategy: ->(_level) { Strategies::PaladinStrategy.new }
        },
        hunter: {
          class: :ranger,
          features: ->(_level) { [Features::ColossusSlayer.new] },
          strategy: ->(_level) { Strategies::RangerStrategy.new }
        },
        life: {
          class: :cleric,
          features: ->(_level) { [Features::DiscipleOfLife.new] },
          strategy: ->(_level) { Strategies::ClericStrategy.new }
        },
        valor: {
          class: :bard,
          features: ->(_level) { [Features::CombatInspiration.new] },
          strategy: ->(_level) { Strategies::BardStrategy.new }
        },
        moon: {
          class: :druid,
          features: ->(level) { [Features::CombatWildShape.new(level: level)] },
          strategy: ->(_level) { Strategies::DruidStrategy.new }
        },
        draconic: {
          class: :sorcerer,
          features: ->(_level) { [Features::DraconicResilience.new] },
          strategy: ->(_level) { Strategies::SorcererStrategy.new }
        },
        fiend: {
          class: :warlock,
          features: ->(_level) { [Features::DarkOnesBlessing.new] },
          strategy: ->(_level) { Strategies::WarlockStrategy.new }
        },
        assassin: {
          class: :rogue,
          features: ->(_level) { [Features::Assassinate.new] },
          strategy: ->(_level) { Strategies::RogueStrategy.new }
        },
        openhand: {
          class: :monk,
          features: ->(_level) { [Features::OpenHandTechnique.new] },
          strategy: ->(_level) { Strategies::MonkStrategy.new }
        }
      }.freeze

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
