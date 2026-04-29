# frozen_string_literal: true

require_relative '../feature'
module Dnd5e
  module Core
    module Features
      # Feature for Cleric Invoke Duplicity.
      class InvokeDuplicity < Feature
        def initialize = super(name: 'Invoke Duplicity')

        def on_attack_roll(context)
          attacker = context[:attacker]
          attacker.condition?(:duplicity_active) ? 2 : 0
        end
      end
    end
  end
end
