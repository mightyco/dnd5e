# frozen_string_literal: true

require_relative '../feature'
require_relative '../dice'

module Dnd5e
  module Core
    module Features
      # Helper for Battle Master maneuvers to keep the main class small.
      module ManeuverHelper
        private

        def maneuver_with_damage?(maneuver)
          %i[menacing_attack trip_attack pushing_attack].include?(maneuver)
        end

        def apply_hit_maneuver(maneuver, context)
          case maneuver
          when :trip_attack then apply_trip_attack(context)
          when :pushing_attack then apply_pushing_attack(context)
          when :menacing_attack then apply_menacing_attack(context)
          end
        end

        def apply_trip_attack(context)
          defender = context[:defender]
          return unless valid_target_size?(defender)

          save_roll = roll_save(defender, :strength, context[:dice_roller])
          success = save_roll < calculate_maneuver_dc(context[:attacker])
          defender.add_condition(:prone) if success
          notify_mastery(context[:options][:combat], context[:attacker], defender, :trip_attack, success)
        end

        def apply_pushing_attack(context)
          defender = context[:defender]
          return unless valid_target_size?(defender)

          save_roll = roll_save(defender, :strength, context[:dice_roller])
          apply_push_effect(save_roll, context)
        end

        def apply_menacing_attack(context)
          defender = context[:defender]
          save_roll = roll_save(defender, :wisdom, context[:dice_roller])
          dc = calculate_maneuver_dc(context[:attacker])
          success = save_roll < dc
          if success
            defender.add_condition(:frightened, { source: context[:attacker], expiry: :turn_end })
          end
          notify_mastery(context[:options][:combat], context[:attacker], defender, :menacing_attack, success)
        end

        def roll_save(defender, ability, roller)
          mod = defender.statblock.save_modifier(ability)
          roller ||= DiceRoller.new
          roller.roll(mod.negative? ? "1d20#{mod}" : "1d20+#{mod}")
        end

        def apply_push_effect(save_roll, context)
          dc = calculate_maneuver_dc(context[:attacker])
          success = save_roll < dc
          if success && context[:options][:combat]
            execute_push(context[:options][:combat], context[:attacker], context[:defender])
          end
          notify_mastery(context[:options][:combat], context[:attacker], context[:defender], :pushing_attack, success)
        end

        def execute_push(combat, attacker, defender)
          attacker_pos = combat.grid.find_position(attacker)
          defender_pos = combat.grid.find_position(defender)
          return unless attacker_pos && defender_pos

          # Calculate direction vector
          dx = defender_pos.x - attacker_pos.x
          dy = defender_pos.y - attacker_pos.y
          mag = Math.sqrt((dx**2) + (dy**2))
          return if mag.zero?

          # Push 15ft away
          push_x = ((dx / mag) * 15).round / 5 * 5
          push_y = ((dy / mag) * 15).round / 5 * 5

          new_pos = Point2D.new(defender_pos.x + push_x, defender_pos.y + push_y)
          combat.grid.move(defender, new_pos)
        end

        def notify_mastery(combat, attacker, defender, mastery, success)
          return unless combat && combat.respond_to?(:notify_observers)

          combat.notify_observers(:mastery_used, {
                                    attacker: attacker, defender: defender,
                                    mastery: mastery, success: success
                                  })
        end

        def valid_target_size?(defender)
          # 2024: Targets must be Large or smaller for these maneuvers
          return true if defender.statblock.size.nil?

          %i[tiny small medium large].include?(defender.statblock.size)
        end

        def calculate_maneuver_dc(attacker)
          8 + attacker.statblock.proficiency_bonus + attacker.statblock.ability_modifier(:strength)
        end

        def apply_precision_attack(context, attacker)
          attacker.statblock.resources.consume(:superiority_dice)
          bonus = attacker.statblock.resources.instance_variable_get(:@dice_roller_override) ||
                  DiceRoller.new.roll("1d#{@die_type}")

          roll_data = context[:current_value]
          roll_data[:total] += bonus
          roll_data[:precision_attack_bonus] = bonus
          
          combat = context.dig(:options, :combat)
          notify_mastery(combat, attacker, context[:defender], :precision_attack, true)
          roll_data
        end
      end

      # Implementation of the Battle Master fighter subclass features.
      class BattleMaster < Feature
        include ManeuverHelper

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
          options = context[:options] || {}
          return [] unless maneuver_with_damage?(options[:maneuver])
          return [] if options[:maneuver_used]

          attacker = context[:attacker]
          return [] unless attacker.statblock.resources.available?(:superiority_dice)

          attacker.statblock.resources.consume(:superiority_dice)
          options[:maneuver_used] = true
          [Dice.new(1, @die_type)]
        end

        def on_after_attack_roll(context)
          options = context[:options] || {}
          return if options[:maneuver] || options[:maneuver_used]

          attacker = context[:attacker]
          return unless attacker.statblock.resources.available?(:superiority_dice)
          return unless attacker.strategy.respond_to?(:should_use_precision_attack?) &&
                        attacker.strategy.should_use_precision_attack?(context)

          options[:maneuver_used] = true
          apply_precision_attack(context, attacker)
        end

        def on_attack_hit(context)
          options = context[:options]
          maneuver = options[:maneuver]
          return unless maneuver_with_damage?(maneuver)

          apply_hit_maneuver(maneuver, context)
        end

        def apply_tactical_shift(attacker, _combat)
          # 2024: Tactical Shift is triggered by Second Wind usage
          attacker.statblock.speed / 2
        end

        private

        def calculate_dice_count(level)
          if level >= 15 then 6
          elsif level >= 7 then 5
          else 4
          end
        end

        def calculate_die_type(level)
          if level >= 18 then 12
          elsif level >= 10 then 10
          else 8
          end
        end
      end
    end
  end
end
