# frozen_string_literal: true

require_relative '../feature'

module Dnd5e
  module Core
    module Features
      # Implementation of the Rogue's Assassin subclass.
      class Assassinate < Feature
        def initialize
          super(name: 'Assassinate')
        end

        def on_attack_roll(context)
          # 2024: Advantage on attacks against creatures that haven't taken a turn
          return 0 unless defender_hasnt_acted?(context[:defender])

          # This would return a modifier or we handle advantage in strategy
          0
        end

        def extra_damage_dice(context)
          attacker = context[:attacker]

          # 2024: Extra damage equal to Rogue level on first hit against creature that hasn't acted
          return [] unless defender_hasnt_acted?(context[:defender])
          return [] if attacker.turn_context.instance_variable_get(:@assassinate_used)

          attacker.turn_context.instance_variable_set(:@assassinate_used, true)
          [Dice.new(1, 1, modifier: attacker.statblock.level - 1)]
        end

        private

        def defender_hasnt_acted?(defender)
          combat = defender.instance_variable_get(:@combat_context)
          return false unless combat

          # Simple check: if round is 1 and defender hasn't had turn yet
          combat.round_counter == 1 && !combat.turn_manager.acted_this_round?(defender)
        end
      end
    end
  end
end
