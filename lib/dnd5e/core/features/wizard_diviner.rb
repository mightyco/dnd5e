# frozen_string_literal: true

require_relative '../feature'

module Dnd5e
  module Core
    module Features
      # Implementation of the Wizard's Diviner subclass: Portent.
      # Feature for Wizard Portent.
      class Portent < Feature
        def initialize
          super(name: 'Portent')
          @rolls = []
        end

        def on_turn_start(_context)
          return if @rolls.any?

          # 2024: Roll 2 d20s at the end of a Long Rest.
          # In simulation, we'll roll them at the start of combat.
          @rolls = [rand(1..20), rand(1..20)]
        end

        def on_attack_roll(context)
          return 0 if @rolls.empty?

          # AI: If the raw roll is low and we have a high portent, replace it.
          raw = context[:raw_roll]
          best_portent = @rolls.max

          if raw < 10 && best_portent > 15
            @rolls.delete_at(@rolls.index(best_portent))
            return best_portent - raw
          end
          0
        end
      end
    end
  end
end
