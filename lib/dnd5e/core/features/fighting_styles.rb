# frozen_string_literal: true

require_relative '../feature'

module Dnd5e
  module Core
    module Features
      # Implementation of the Archery Fighting Style.
      class ArcheryStyle < Feature
        def initialize
          super(name: 'Fighting Style: Archery')
        end

        def on_attack_roll(context)
          attack = context[:attack]
          return 0 unless attack.properties.include?(:ranged)

          2
        end
      end
    end
  end
end
