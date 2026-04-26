# frozen_string_literal: true

require_relative '../feature'

module Dnd5e
  module Core
    module Features
      # Implementation of the Barbarian's Path of the Berserker subclass.
      class Frenzy < Feature
        def initialize
          super(name: 'Frenzy')
        end

        def on_damage_calculation(context)
          attacker = context[:attacker]
          return nil unless can_frenzy?(attacker, context[:options])

          attacker.turn_context.instance_variable_set(:@frenzy_used, true)
          calculate_frenzy_dice(attacker, context[:dice])
        end

        private

        def can_frenzy?(attacker, options)
          attacker.condition?(:raging) &&
            options[:reckless] &&
            !attacker.turn_context.instance_variable_get(:@frenzy_used)
        end

        def calculate_frenzy_dice(attacker, base_dice)
          rage_feat = attacker.feature_manager.features.find { |f| f.is_a?(Rage) }
          dice_count = rage_feat ? rage_feat.damage_bonus : 2

          Dice.new(base_dice.count + dice_count, 6, modifier: base_dice.modifier)
        end
      end
    end
  end
end
