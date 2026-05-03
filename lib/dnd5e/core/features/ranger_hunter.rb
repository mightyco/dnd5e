# frozen_string_literal: true

require_relative '../feature'

module Dnd5e
  module Core
    module Features
      # 2024 Hunter: Colossus Slayer
      class ColossusSlayer < Feature
        def initialize
          super(name: 'Colossus Slayer')
        end

        def on_attack_hit(context)
          attacker = context[:attacker]
          defender = context[:defender]

          return if already_used?(attacker)
          return unless wounded?(defender)

          apply_extra_damage(attacker, context)
        end

        private

        def already_used?(attacker)
          attacker.turn_context.flags[:colossus_slayer_used]
        end

        def wounded?(defender)
          defender.statblock.hit_points < defender.statblock.max_hp
        end

        def apply_extra_damage(attacker, context)
          extra_damage = DiceRoller.new.roll('1d8')
          context[:result][:damage] += extra_damage
          attacker.turn_context.flags[:colossus_slayer_used] = true
        end
      end

      # 2024 Hunter: Horde Breaker
      class HordeBreaker < Feature
        def initialize
          super(name: 'Horde Breaker')
        end

        def on_attack_hit(context)
          attacker = context[:attacker]
          nil if attacker.turn_context.flags[:horde_breaker_used]

          # Trigger strategy to attempt an extra attack if possible
          # Handled by extra_attack_helper
        end
      end
    end
  end
end
