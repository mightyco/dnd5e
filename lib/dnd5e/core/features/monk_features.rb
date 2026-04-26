# frozen_string_literal: true

require_relative '../feature'

module Dnd5e
  module Core
    module Features
      # Implementation of the Monk's Martial Arts feature.
      class MartialArts < Feature
        def initialize
          super(name: 'Martial Arts')
        end

        def on_turn_start(context)
          # Monk can use a Bonus Action to make an Unarmed Strike if they use an attack.
          # Handled by strategy.
        end
      end

      # Implementation of the Monk's Flurry of Blows.
      class FlurryOfBlows < Feature
        def initialize
          super(name: 'Flurry of Blows')
        end

        def try_activate(attacker, _combat)
          return unless attacker.statblock.resources.available?(:focus_points)
          return unless attacker.turn_context.bonus_action_available?

          attacker.statblock.resources.consume(:focus_points)
          # 2024: Flurry of Blows is two unarmed strikes as a Bonus Action.
          # Strategy will execute these.
          attacker.turn_context.use_bonus_action
          true
        end
      end
    end
  end
end
