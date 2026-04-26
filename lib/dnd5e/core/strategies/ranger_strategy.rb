# frozen_string_literal: true

require_relative 'simple_strategy'

module Dnd5e
  module Core
    module Strategies
      # Strategy for Rangers.
      class RangerStrategy < SimpleStrategy
        def initialize
          super
          @name = 'Ranger'
        end

        def execute_turn(combatant, combat)
          try_hunters_mark(combatant, combat)

          target, attack = prepare_turn_data(combatant, combat)
          move_towards_target(combatant, target, attack, combat) if target && attack

          execute_action(combatant, combat)
        end

        private

        def try_hunters_mark(combatant, combat)
          mark_feat = combatant.feature_manager.features.find { |f| f.name == "Hunter's Mark" }
          mark_feat&.try_activate(combatant, combat)
        end
      end
    end
  end
end
