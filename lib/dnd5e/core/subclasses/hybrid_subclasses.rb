# frozen_string_literal: true

module Dnd5e
  module Core
    module Subclasses
      # Definitions for hybrid class subclasses (Paladin, Ranger).
      HYBRID_SUBCLASSES = {
        devotion: {
          class: :paladin,
          features: ->(_level) { [Features::SacredWeapon.new] },
          strategy: ->(_level) { Strategies::PaladinStrategy.new }
        },
        vengeance: {
          class: :paladin,
          features: ->(_level) { [Features::VowOfEnmity.new] },
          strategy: ->(_level) { Strategies::PaladinStrategy.new }
        },
        glory: {
          class: :paladin,
          features: ->(_level) { [Features::PeerlessAthlete.new] },
          strategy: ->(_level) { Strategies::PaladinStrategy.new }
        },
        hunter: {
          class: :ranger,
          features: ->(_level) { [Features::ColossusSlayer.new] },
          strategy: ->(_level) { Strategies::RangerStrategy.new }
        },
        beast_master: {
          class: :ranger,
          features: ->(_level) { [Features::PrimalCompanion.new] },
          strategy: ->(_level) { Strategies::RangerStrategy.new }
        },
        fey_wanderer: {
          class: :ranger,
          features: ->(_level) { [Features::DreadfulStrike.new] },
          strategy: ->(_level) { Strategies::RangerStrategy.new }
        }
      }.freeze
    end
  end
end
