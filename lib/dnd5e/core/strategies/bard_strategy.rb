# frozen_string_literal: true

require_relative 'simple_strategy'

module Dnd5e
  module Core
    module Strategies
      # Strategy for Bards.
      class BardStrategy < SimpleStrategy
        def initialize
          super
          @name = 'Bard'
        end

        def execute_turn(combatant, combat)
          try_bardic_inspiration(combatant, combat)

          target, attack = prepare_turn_data(combatant, combat)
          move_towards_target(combatant, target, attack, combat) if target && attack

          execute_action(combatant, combat)
        end

        private

        def try_bardic_inspiration(combatant, combat)
          insp_feat = combatant.feature_manager.features.find { |f| f.name == 'Bardic Inspiration' }
          insp_feat&.try_activate(combatant, nil, combat)
        end
      end
    end
  end
end
