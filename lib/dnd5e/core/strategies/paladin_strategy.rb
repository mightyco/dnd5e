# frozen_string_literal: true

require_relative 'simple_strategy'

module Dnd5e
  module Core
    module Strategies
      # Strategy for Paladins.
      class PaladinStrategy < SimpleStrategy
        def initialize
          super
          @name = 'Paladin'
        end

        def execute_turn(combatant, combat)
          try_sacred_weapon(combatant, combat)

          target, attack = prepare_turn_data(combatant, combat)
          move_towards_target(combatant, target, attack, combat) if target && attack

          execute_action(combatant, combat)
        end

        private

        def try_sacred_weapon(combatant, combat)
          sacred_feat = combatant.feature_manager.features.find { |f| f.name == 'Sacred Weapon' }
          sacred_feat&.try_activate(combatant, combat)
        end
      end
    end
  end
end
