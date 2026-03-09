# frozen_string_literal: true

require_relative '../feature'

module Dnd5e
  module Core
    module Features
      # Implementation of the Dual Wielder feat (2024).
      # Grants an extra attack as a Bonus Action when attacking with a Light weapon.
      class DualWielder < Feature
        def initialize
          super(name: 'Dual Wielder')
        end
      end
    end
  end
end
