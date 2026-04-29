# frozen_string_literal: true

require_relative '../feature'

module Dnd5e
  module Core
    module Features
      # Implementation of the Monk's Warrior of the Open Hand subclass: Open Hand Technique.
      class OpenHandTechnique < Feature
        def initialize
          super(name: 'Open Hand Technique')
        end

        # 2024 Rules: When you hit a creature with an attack granted by Flurry of Blows,
        # you can impose one of the following effects:
        # Addle: The target can't take Reactions until the start of its next turn.
        # Push: The target must succeed on a Strength saving throw or be pushed up to 15 feet away.
        # Topple: The target must succeed on a Dexterity saving throw or be knocked Prone.
        def on_attack_hit(context)
          attacker = context[:attacker]
          defender = context[:defender]
          attack = context[:attack]

          # Only applies to Flurry of Blows attacks
          return unless attack.name == 'Flurry of Blows'

          # For simulation purposes, we'll choose the best effect based on context.
          # If target can take reactions, Addle is good.
          # If target is not prone, Topple is usually best for DPR.
          apply_technique(attacker, defender, context[:combat])
        end

        private

        def apply_technique(attacker, defender, combat)
          # Simplified AI: Try to Topple first for advantage on subsequent attacks
          if !defender.condition?(:prone)
            topple(attacker, defender, combat)
          elsif defender.turn_context.reactions_used.zero?
            addle(attacker, defender)
          end
        end

        def topple(attacker, defender, combat)
          dc = 8 + attacker.statblock.ability_modifier(:wisdom) + attacker.statblock.proficiency_bonus
          roller = combat&.dice_roller || DiceRoller.new
          roll = roller.roll('1d20') + defender.statblock.save_modifier(:dexterity)

          return unless roll < dc

          defender.add_condition(:prone)
          attacker.instance_variable_get(:@combat_context)&.notify_observers(
            :condition_applied, { target: defender, condition: :prone }
          )
        end

        def addle(_attacker, defender)
          # Addle doesn't require a save in 2024?
          # Actually, PHB 2024: "Addle: The target can't take Reactions until the start of its next turn."
          # No save mentioned in some previews, let's check...
          # PHB 2024: "Addle. The target can't take Reactions until the start of its next turn." No save.
          defender.turn_context.use_reaction # Force a reaction use to "disable" it
          defender.add_condition(:addled, { expiry: :turn_start })
        end
      end
    end
  end
end
