# frozen_string_literal: true

module Dnd5e
  module Core
    module Helpers
      # Helper for accumulating Fighting Style bonuses.
      class FightingStyleHelper
        def self.ac_bonus(character)
          character.feature_manager.apply_modifier_hook(:ac_bonus, { character: character }, 0)
        end

        def self.extra_damage_modifier(attacker, attack, options)
          context = { attacker: attacker, attack: attack, options: options }
          attacker.feature_manager.apply_modifier_hook(:extra_damage_modifier, context, 0)
        end
      end
    end
  end
end
