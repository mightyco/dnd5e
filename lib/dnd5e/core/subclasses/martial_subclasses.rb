# frozen_string_literal: true

module Dnd5e
  module Core
    module Subclasses
      # Definitions for martial class subclasses (Barbarian, Fighter, Monk, Rogue).
      MARTIAL_SUBCLASSES = {
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
        eldritch_knight: {
          class: :fighter,
          features: ->(_level) { [Features::WarBond.new] },
          strategy: ->(_level) { Strategies::SimpleStrategy.new }
        },
        berserker: {
          class: :barbarian,
          features: ->(_level) { [Features::Frenzy.new] },
          strategy: ->(_level) { Strategies::BarbarianStrategy.new }
        },
        wild_heart: {
          class: :barbarian,
          features: ->(_level) { [Features::WildHeartFeatures.new] },
          strategy: ->(_level) { Strategies::BarbarianStrategy.new }
        },
        zealot: {
          class: :barbarian,
          features: ->(level) { [Features::DivineFury.new(level: level)] },
          strategy: ->(_level) { Strategies::BarbarianStrategy.new }
        },
        openhand: {
          class: :monk,
          features: ->(_level) { [Features::OpenHandTechnique.new] },
          strategy: ->(_level) { Strategies::MonkStrategy.new }
        },
        elements: {
          class: :monk,
          features: ->(_level) { [Features::ElementalReach.new] },
          strategy: ->(_level) { Strategies::MonkStrategy.new }
        },
        shadow: {
          class: :monk,
          features: ->(_level) { [Features::ShadowArts.new] },
          strategy: ->(_level) { Strategies::MonkStrategy.new }
        },
        assassin: {
          class: :rogue,
          features: ->(_level) { [Features::Assassinate.new] },
          strategy: ->(_level) { Strategies::RogueStrategy.new }
        },
        thief: {
          class: :rogue,
          features: ->(_level) { [Features::ThiefFeatures.new] },
          strategy: ->(_level) { Strategies::RogueStrategy.new }
        },
        arcane_trickster: {
          class: :rogue,
          features: ->(_level) { [] },
          strategy: ->(_level) { Strategies::RogueStrategy.new }
        }
      }.freeze
    end
  end
end
