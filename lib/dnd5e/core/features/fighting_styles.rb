# frozen_string_literal: true

require_relative '../feature'

module Dnd5e
  module Core
    module Features
      # Implementation of the Archery Fighting Style.
      class ArcheryStyle < Feature
        def initialize
          super(name: 'Fighting Style: Archery')
        end

        def on_attack_roll(context)
          attack = context[:attack]
          return 0 unless attack.properties.include?(:ranged)

          2
        end
      end

      # Implementation of the Defense Fighting Style.
      class DefenseStyle < Feature
        def initialize
          super(name: 'Fighting Style: Defense')
        end

        def ac_bonus(context)
          character = context[:character]
          # 2024: +1 AC if wearing light, medium, or heavy armor
          character.statblock.equipped_armor ? 1 : 0
        end
      end

      # Implementation of the Dueling Fighting Style.
      class DuelingStyle < Feature
        def initialize
          super(name: 'Fighting Style: Dueling')
        end

        def extra_damage_modifier(context)
          attack = context[:attack]
          # 2024: +2 to damage with melee weapons held in one hand (no other weapons)
          return 0 unless attack.properties.include?(:melee)
          # Assuming versatile weapon used 1-handed or standard 1-handed melee weapon.
          # Simplification: if it doesn't have :two_handed property.
          return 0 if attack.properties.include?(:two_handed)

          2
        end
      end

      # Implementation of the Great Weapon Fighting Style.
      class GreatWeaponFightingStyle < Feature
        def initialize
          super(name: 'Fighting Style: Great Weapon Fighting')
        end

        def on_damage_roll_modification(_context)
          # 2024: When you roll a 1 or 2 on a damage die for an attack with a
          # two-handed or versatile melee weapon, you can reroll the die.
          # (Simplified for now or implemented in DiceRoller hooks if available)
          0
        end
      end

      # Implementation of the Protection Fighting Style.
      class ProtectionStyle < Feature
        def initialize
          super(name: 'Fighting Style: Protection')
        end
      end

      # Implementation of the Two-Weapon Fighting Style.
      class TwoWeaponFightingStyle < Feature
        def initialize
          super(name: 'Fighting Style: Two-Weapon Fighting')
        end
        # Handled in DamageRollHelper via name check for now.
      end
    end
  end
end
