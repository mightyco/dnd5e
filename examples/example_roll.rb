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
      
        puts "Sampling many dice rolls of 3d6" 
        total = 0
        dice = Core::Dice.new(3, 6)
        10000.times do
          dice.roll
          total += dice.total
        end
        puts "Average: #{total/10000.0}"
      end
    end
  end
end

Dnd5e::Examples::Roll.run
