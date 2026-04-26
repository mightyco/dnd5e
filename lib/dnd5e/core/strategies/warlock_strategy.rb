# frozen_string_literal: true

require_relative 'simple_strategy'

module Dnd5e
  module Core
    module Strategies
      # Strategy for Warlocks.
      class WarlockStrategy < SimpleStrategy
        def initialize
          super
          @name = 'Warlock'
        end

        def execute_turn(combatant, combat)
          target, attack = prepare_turn_data(combatant, combat)
          move_towards_target(combatant, target, attack, combat) if target && attack

          execute_action(combatant, combat)
        end
      end
    end
  end
end
