require_relative "../lib/dnd5e/core/dice"

module Dnd5e
  module Examples
    class Roll
      def self.run(args)
        if args.length != 1
          puts "Usage: ruby roll.rb <dice_notation>"
          puts "Example: ruby roll.rb 2d20"
          return
        end

        dice_notation = args[0]
        match_data = dice_notation.match(/(\d+)d(\d+)/)

        if match_data.nil?
          puts "Invalid dice notation. Use format like 2d20"
          return
        end

        count = match_data[1].to_i
        sides = match_data[2].to_i

        if count <= 0 || sides <= 0
          puts "Dice count and sides must be greater than 0"
          return
        end

        dice = Core::Dice.new(count, sides)
        puts "Rolling #{dice}..."
        rolls = dice.roll
        puts "Rolls: #{rolls.join(', ')}"
        puts "Total: #{dice.total}"
      end
    end
  end
end

Dnd5e::Examples::Roll.run(ARGV)
