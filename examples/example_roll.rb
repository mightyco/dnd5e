require_relative "../lib/dnd5e/core/dice"

module Dnd5e
  module Examples
    class Roll
      def self.run
        dice = Core::Dice.new(3, 6, modifier: 2)
        puts "Rolling #{dice}..."
        rolls = dice.roll
        puts "Rolls: #{rolls.join(', ')}"
        puts "Total: #{dice.total}"
      end
    end
  end
end

Dnd5e::Examples::Roll.run
