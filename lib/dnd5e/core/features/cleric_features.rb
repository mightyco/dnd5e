# frozen_string_literal: true

require_relative '../feature'

module Dnd5e
  module Core
    module Features
      # Implementation of the Cleric's Divine Spark feature (Channel Divinity).
      class DivineSpark < Feature
        def initialize
          super(name: 'Divine Spark')
        end

        def try_activate(attacker, target, combat)
          return unless attacker.statblock.resources.available?(:channel_divinity)
          return unless attacker.turn_context.action_available?

          attacker.statblock.resources.consume(:channel_divinity)
          execute_spark(attacker, target, combat)
          attacker.turn_context.use_action
          true
        end

        private

        def execute_spark(attacker, target, combat)
          dc = 8 + attacker.statblock.proficiency_bonus + attacker.statblock.ability_modifier(:wisdom)
          damage = calculate_spark_damage(attacker)
          damage /= 2 if save_success?(target, dc)

          target.statblock.take_damage(damage)
          combat.notify_observers(:resource_used, { combatant: attacker, resource: :channel_divinity })
        end

        def calculate_spark_damage(attacker)
          DiceRoller.new.roll("#{(attacker.statblock.level / 6).to_i + 1}d8")
        end

        def save_success?(target, save_dc)
          save_struct = Struct.new(:save_ability, :dice_roller).new(:constitution, DiceRoller.new)
          Helpers::SaveResolutionHelper.roll_save(target, save_struct)[:total] >= save_dc
        end
      end

      # Implementation of the Life Domain's Disciple of Life.
      class DiscipleOfLife < Feature
        def initialize
          super(name: 'Disciple of Life')
        end
      end
    end
  end
end
