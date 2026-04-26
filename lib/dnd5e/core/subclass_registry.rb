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
          features: ->(level) { [Features::BattleMaster.new(level: level)] },
          strategy: ->(_level) { Strategies::BattleMasterStrategy.new }
        },
        champion: {
          features: ->(_level) { [Features::ImprovedCritical.new] },
          strategy: ->(_level) { Strategies::SimpleStrategy.new }
        },
        evoker: {
          features: ->(_level) { [Features::SculptSpells.new, Features::EmpoweredEvocation.new] },
          strategy: ->(_level) { Strategies::SimpleStrategy.new }
        },
        abjurer: {
          features: ->(level) { [Features::ArcaneWard.new(level: level)] },
          strategy: ->(_level) { Strategies::SimpleStrategy.new }
        },
        berserker: {
          features: ->(_level) { [Features::Frenzy.new] },
          strategy: ->(_level) { Strategies::BarbarianStrategy.new }
        },
        devotion: {
          features: ->(_level) { [Features::SacredWeapon.new] },
          strategy: ->(_level) { Strategies::PaladinStrategy.new }
        },
        hunter: {
          features: ->(_level) { [Features::ColossusSlayer.new] },
          strategy: ->(_level) { Strategies::RangerStrategy.new }
        },
        life: {
          features: ->(_level) { [Features::DiscipleOfLife.new] },
          strategy: ->(_level) { Strategies::ClericStrategy.new }
        },
        valor: {
          features: ->(_level) { [] }, # Placeholder for valor specific features
          strategy: ->(_level) { Strategies::BardStrategy.new }
        },
        moon: {
          features: ->(_level) { [] }, # Placeholder for moon specific features
          strategy: ->(_level) { Strategies::DruidStrategy.new }
        },
        draconic: {
          features: ->(_level) { [Features::DraconicResilience.new] },
          strategy: ->(_level) { Strategies::SorcererStrategy.new }
        },
        fiend: {
          features: ->(_level) { [Features::DarkOnesBlessing.new] },
          strategy: ->(_level) { Strategies::WarlockStrategy.new }
        },
        assassin: {
          features: ->(_level) { [Features::Assassinate.new] },
          strategy: ->(_level) { Strategies::RogueStrategy.new }
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
