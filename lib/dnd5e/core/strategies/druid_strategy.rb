# frozen_string_literal: true

require_relative 'simple_strategy'

module Dnd5e
  module Core
    module Strategies
      # Strategy for Druids.
      class DruidStrategy < SimpleStrategy
        def initialize
          super
          @name = 'Druid'
        end

        def execute_turn(combatant, combat)
          try_wild_shape(combatant, combat)

          target, attack = prepare_turn_data(combatant, combat)
          move_towards_target(combatant, target, attack, combat) if target && attack

          execute_action(combatant, combat)
        end

        private

        def try_wild_shape(combatant, combat)
          wild_feat = combatant.feature_manager.features.find { |f| f.name == 'Wild Shape' }
          wild_feat&.try_activate(combatant, combat)
        end
      end
    end
  end
end
