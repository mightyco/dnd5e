# frozen_string_literal: true

require_relative '../feature'

module Dnd5e
  module Core
    module Features
      # Implementation of the Fighter's Eldritch Knight subclass: War Bond.
      # Feature for Fighter War Bond.
      class WarBond < Feature
        def initialize
          super(name: 'War Bond')
        end

        def on_character_init(context)
          char = context[:character]
          # 2024: Eldritch Knight can't be disarmed of their bonded weapon.
          # We'll represent this as a minor damage/accuracy boost for simulation.
          char.attacks.each do |atk|
            atk.instance_variable_set(:@magic_bonus, atk.instance_variable_get(:@magic_bonus) + 1)
          end
        end
      end
    end
  end
end
