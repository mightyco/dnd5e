# frozen_string_literal: true

require_relative '../feature'

module Dnd5e
  module Core
    module Features
      # Implementation of the Cleric's Light Domain: Warding Flare.
      # Feature for Cleric Warding Flare.
      class WardingFlare < Feature
        def initialize
          super(name: 'Warding Flare')
        end

        def on_after_attack_roll(context, roll_data)
          defender = context[:defender]
          return roll_data unless flare_available?(defender) && !roll_data[:disadvantage]

          defender.turn_context.use_reaction
          defender.statblock.resources.consume(:warding_flare)

          apply_disadvantage_roll(roll_data)
        end

        private

        def flare_available?(defender)
          defender.turn_context.reaction_available? &&
            defender.statblock.resources.available?(:warding_flare)
        end

        def apply_disadvantage_roll(roll_data)
          second_roll = rand(1..20)
          new_raw = [roll_data[:raw], second_roll].min
          build_disadvantage_result(roll_data, new_raw, second_roll)
        end

        def build_disadvantage_result(roll_data, new_raw, second_roll)
          {
            total: new_raw + roll_data[:modifier],
            raw: new_raw,
            modifier: roll_data[:modifier],
            is_crit: new_raw == 20,
            rolls: roll_data[:rolls] + [second_roll],
            advantage: roll_data[:advantage],
            disadvantage: true
          }
        end
      end
    end
  end
end
