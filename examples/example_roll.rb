# frozen_string_literal: true

require_relative '../lib/dnd5e/core/dice_roller'

module Dnd5e
  module Examples
    # Example of rolling dice.
    class Roll
      def self.run
        puts 'Rolling 1d20:'
        puts Core::DiceRoller.new.roll('1d20')

        puts 'Rolling 2d6+3:'
        puts Core::DiceRoller.new.roll('2d6+3')

        puts 'Rolling with advantage (d20):'
        puts Core::DiceRoller.new.roll_with_advantage(20)
      end
    end
  end
end

Dnd5e::Examples::Roll.run
