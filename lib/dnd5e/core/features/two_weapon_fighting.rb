# frozen_string_literal: true

require_relative '../feature'

module Dnd5e
  module Core
    module Features
      # Implementation of the Two-Weapon Fighting fighting style (2024).
      # Adds ability modifier to damage of extra attacks.
      class TwoWeaponFighting < Feature
        def initialize
          super(name: 'Two-Weapon Fighting')
        end
      end
    end
  end
end
