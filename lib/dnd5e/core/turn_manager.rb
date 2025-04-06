require_relative "dice"
require_relative "dice_roller"

module Dnd5e
  module Core
    class TurnManager
      class NoCombatantsError < StandardError; end

      attr_reader :combatants, :turn_order
      attr_writer :dice_roller

      def initialize(combatants:, dice_roller: DiceRoller.new)
        @combatants = combatants
        @turn_order = []
        @current_turn_index = 0
        @dice_roller = dice_roller
      end

      def roll_initiative
        @combatants.each do |combatant|
          combatant.instance_variable_set(:@initiative, @dice_roller.roll("1d20") + combatant.statblock.ability_modifier(:dexterity))
        end
      end

      def sort_by_initiative
        @turn_order = @combatants.sort_by { |combatant| [-combatant.instance_variable_get(:@initiative), -combatant.statblock.ability_modifier(:dexterity)] }
      end

      def next_turn
        raise NoCombatantsError, "No combatants in the turn manager" if @combatants.empty?

        @current_turn_index = (@current_turn_index + 1) % @turn_order.size
        @turn_order[@current_turn_index]
      end

      def all_turns_complete?
        @current_turn_index == 0 && @turn_order.size > 0
      end

      def add_combatant(combatant)
        @combatants << combatant
      end

      def remove_combatant(combatant)
        @combatants.delete(combatant)
      end
    end
  end
end
