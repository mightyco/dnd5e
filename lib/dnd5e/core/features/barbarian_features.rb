# frozen_string_literal: true

require_relative '../feature'

module Dnd5e
  module Core
    module Features
      # Implementation of the Barbarian's Rage feature.
      class Rage < Feature
        attr_reader :damage_bonus

        def initialize(damage_bonus: 2)
          super(name: 'Rage')
          @damage_bonus = damage_bonus
        end

        def on_damage_calculation(context)
          attacker = context[:attacker]
          attack = context[:attack]

          # 2024: Rage damage applies to Strength-based attacks
          return nil unless attacker.condition?(:raging) && attack.relevant_stat == :strength

          # Add static bonus to the dice modifier
          dice = context[:dice]
          Dice.new(dice.count, dice.sides, modifier: dice.modifier + @damage_bonus)
        end

        def on_damage_taken(context)
          defender = context[:defender]
          return nil unless defender.condition?(:raging)

          # Rage provides resistance to bludgeoning, piercing, slashing
          damage = context[:damage]
          (damage / 2).to_i
        end
      end

      # Implementation of the Barbarian's Reckless Attack feature.
      class RecklessAttack < Feature
        def initialize
          super(name: 'Reckless Attack')
        end

        def on_attack_roll(context)
          options = context[:options]

          return 0 unless options[:reckless] && context[:attack].relevant_stat == :strength

          # Logic to add advantage is handled by the strategy or a general hook
          0
        end
      end
    end
  end
end
