# frozen_string_literal: true

require_relative 'simple_strategy'

module Dnd5e
  module Core
    module Strategies
      # Strategy for Sorcerers.
      class SorcererStrategy < SimpleStrategy
        def initialize
          super
          @name = 'Sorcerer'
        end

        def execute_turn(combatant, combat)
          try_innate_sorcery(combatant, combat)

          target, attack = prepare_turn_data(combatant, combat)
          move_towards_target(combatant, target, attack, combat) if target && attack

          execute_action(combatant, combat)
        end

        private

        def try_innate_sorcery(combatant, combat)
          sorcery_feat = combatant.feature_manager.features.find { |f| f.name == 'Innate Sorcery' }
          sorcery_feat&.try_activate(combatant, combat)
        end
      end
    end
  end
end
