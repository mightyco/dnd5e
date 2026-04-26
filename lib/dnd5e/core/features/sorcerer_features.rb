# frozen_string_literal: true

require_relative '../feature'

module Dnd5e
  module Core
    module Features
      # Implementation of the Sorcerer's Innate Sorcery feature.
      class InnateSorcery < Feature
        def initialize
          super(name: 'Innate Sorcery')
        end

        def try_activate(attacker, combat)
          return if attacker.condition?(:innate_sorcery_active)
          return unless attacker.turn_context.bonus_action_available?

          attacker.add_condition(:innate_sorcery_active, { expiry: :turn_end, duration: 10 })
          combat.notify_observers(:resource_used, { combatant: attacker, resource: :innate_sorcery })
          attacker.turn_context.use_bonus_action
          true
        end

        def on_attack_roll(context)
          attacker = context[:attacker]
          return 0 unless attacker.condition?(:innate_sorcery_active)

          # Increased attack rolls for spells
          1
        end
      end

      # Implementation of the Draconic Sorcerer's resilience.
      class DraconicResilience < Feature
        def initialize
          super(name: 'Draconic Resilience')
        end

        def on_character_init(context)
          character = context[:character]
          # AC = 13 + Dex
          character.statblock.instance_variable_set(:@base_ac_override, 13)
        end
      end
    end
  end
end
