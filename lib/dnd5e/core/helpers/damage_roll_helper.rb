# frozen_string_literal: true

require_relative '../dice'

module Dnd5e
  module Core
    module Helpers
      # Helper for damage roll calculations.
      class DamageRollHelper
        # rubocop:disable Metrics/AbcSize
        def self.calculate_modifier(attacker, attack, options)
          # Start with weapon's built-in modifier and magic bonus
          base_mod = attack.damage_dice.modifier + (attack.respond_to?(:magic_bonus) ? attack.magic_bonus : 0)

          # Add ability modifier
          ability_mod = attacker.statblock.ability_modifier(attack.relevant_stat)

          # 2024 Two-Weapon Fighting rules:
          # If it's an offhand attack, only add ability modifier if they have the TWF Fighting Style.
          if options[:offhand]
            has_twf_style = attacker.feature_manager.features.any? { |f| f.name.include?('Two-Weapon Fighting') }
            ability_mod = 0 unless has_twf_style
          end

          # Unified Feature Modifier Hook
          context = { attacker: attacker, attack: attack, options: options }
          feature_mod = attacker.feature_manager.apply_modifier_hook(:extra_damage_modifier, context, 0)

          base_mod + ability_mod + feature_mod
        end
        # rubocop:enable Metrics/AbcSize

        def self.calculate_dice(attacker, attack, is_crit, options)
          count = attack.damage_dice.count
          count *= 2 if is_crit
          Dice.new(count, attack.damage_dice.sides)
        end

        def self.roll_extra(attacker, defender, attack, options)
          context = { attacker: attacker, defender: defender, attack: attack, options: options }
          extra_dice_list = attacker.feature_manager.apply_list_hook(:extra_damage_dice, context)

          total = 0
          rolls = []
          extra_dice_list.each do |dice|
            dice_total = attack.dice_roller.roll_with_dice(dice)
            total += dice_total
            rolls += attack.dice_roller.dice.rolls
          end

          [total, rolls]
        end
      end
    end
  end
end
