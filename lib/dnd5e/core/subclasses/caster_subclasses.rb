# frozen_string_literal: true

module Dnd5e
  module Core
    module Subclasses
      # Definitions for caster class subclasses.
      CASTER_SUBCLASSES = {
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
        diviner: {
          class: :wizard,
          features: ->(_level) { [Features::Portent.new] },
          strategy: ->(_level) { Strategies::SimpleStrategy.new }
        },
        lore: {
          class: :bard,
          features: ->(_level) { [Features::CuttingWords.new] },
          strategy: ->(_level) { Strategies::BardStrategy.new }
        },
        valor: {
          class: :bard,
          features: ->(_level) { [Features::CombatInspiration.new] },
          strategy: ->(_level) { Strategies::BardStrategy.new }
        },
        glamour: {
          class: :bard,
          features: ->(_level) { [Features::MantleOfInspiration.new] },
          strategy: ->(_level) { Strategies::BardStrategy.new }
        },
        life: {
          class: :cleric,
          features: ->(_level) { [Features::DiscipleOfLife.new] },
          strategy: ->(_level) { Strategies::ClericStrategy.new }
        },
        light: {
          class: :cleric,
          features: ->(_level) { [Features::WardingFlare.new] },
          strategy: ->(_level) { Strategies::ClericStrategy.new }
        },
        trickery: {
          class: :cleric,
          features: ->(_level) { [Features::InvokeDuplicity.new] },
          strategy: ->(_level) { Strategies::ClericStrategy.new }
        },
        moon: {
          class: :druid,
          features: ->(level) { [Features::CombatWildShape.new(level: level)] },
          strategy: ->(_level) { Strategies::DruidStrategy.new }
        },
        land: {
          class: :druid,
          features: ->(_level) { [Features::LandCircle.new] },
          strategy: ->(_level) { Strategies::DruidStrategy.new }
        },
        sea: {
          class: :druid,
          features: ->(_level) { [Features::WrathOfTheSea.new] },
          strategy: ->(_level) { Strategies::DruidStrategy.new }
        },
        draconic: {
          class: :sorcerer,
          features: ->(_level) { [Features::DraconicResilience.new] },
          strategy: ->(_level) { Strategies::SorcererStrategy.new }
        },
        wild_magic: {
          class: :sorcerer,
          features: ->(_level) { [Features::TidesOfChaos.new] },
          strategy: ->(_level) { Strategies::SorcererStrategy.new }
        },
        aberrant: {
          class: :sorcerer,
          features: ->(_level) { [Features::PsionicSorcery.new] },
          strategy: ->(_level) { Strategies::SorcererStrategy.new }
        },
        fiend: {
          class: :warlock,
          features: ->(_level) { [Features::DarkOnesBlessing.new] },
          strategy: ->(_level) { Strategies::WarlockStrategy.new }
        },
        archfey: {
          class: :warlock,
          features: ->(_level) { [Features::MistyStep.new] },
          strategy: ->(_level) { Strategies::WarlockStrategy.new }
        },
        goo: {
          class: :warlock,
          features: ->(_level) { [Features::AwakenedMind.new] },
          strategy: ->(_level) { Strategies::WarlockStrategy.new }
        }
      }.freeze
    end
  end
end
