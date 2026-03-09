# frozen_string_literal: true

require_relative '../feature'
require_relative '../dice'

module Dnd5e
  module Core
    module Features
      # Implementation of the Battle Master fighter subclass features.
      class BattleMaster < Feature
        attr_reader :die_type, :level

        def initialize(level: 3)
          super(name: 'Battle Master')
          @level = level
          @die_type = calculate_die_type(level)
        end

        def on_character_init(context)
          character = context[:character]
          dice_count = calculate_dice_count(@level)
          character.statblock.resources.set_max(:superiority_dice, dice_count)
        end

        def extra_damage_dice(context)
          options = context[:options]
          return [] unless options[:maneuver] && options[:maneuver] != :precision_attack

          attacker = context[:attacker]
          return [] unless attacker.statblock.resources.available?(:superiority_dice)

          attacker.statblock.resources.consume(:superiority_dice)
          [Dice.new(1, @die_type)]
        end

        def on_after_attack_roll(context)
          attacker = context[:attacker]
          return unless attacker.statblock.resources.available?(:superiority_dice)

          # Check if strategy wants to use precision attack
          return unless attacker.strategy.respond_to?(:should_use_precision_attack?) &&
                        attacker.strategy.should_use_precision_attack?(context)

          apply_precision_attack(context, attacker)
        end

        private

        def apply_precision_attack(context, attacker)
          attacker.statblock.resources.consume(:superiority_dice)
          bonus = attacker.statblock.resources.instance_variable_get(:@dice_roller_override) ||
                  DiceRoller.new.roll("1d#{@die_type}")

          roll_data = context[:current_value]
          roll_data[:total] += bonus
          roll_data[:precision_attack_bonus] = bonus
          roll_data
        end

        def calculate_dice_count(level)
          if level >= 15
            6
          elsif level >= 7
            5
          else
            4
          end
        end

        def calculate_die_type(level)
          if level >= 18
            12
          elsif level >= 10
            10
          else
            8
          end
        end
      end
    end
  end
end
