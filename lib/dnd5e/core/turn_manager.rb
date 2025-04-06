require_relative "dice"

module Dnd5e
  module Core
    class TurnManager
      class NoCombatantsError < StandardError; end # Define a custom exception

      attr_reader :combatants, :turn_order

      def initialize(combatants:)
        @combatants = combatants
        @turn_order = []
        @current_turn_index = 0
      end

      def roll_initiative
        @turn_order.clear # Clear the turn order before rolling initiative
        @combatants.each do |combatant|
          initiative_roll = Dice.new(1, 20, modifier: combatant.statblock.ability_modifier(:dexterity)).roll.first
          combatant.instance_variable_set(:@initiative, initiative_roll)
          @turn_order << combatant
        end
      end

      def sort_by_initiative
        @turn_order.sort_by! { |combatant| [-combatant.instance_variable_get(:@initiative), -combatant.statblock.dexterity] }
      end

      def next_turn
        raise NoCombatantsError, "No combatants in turn order" if @turn_order.empty?

        combatant = @turn_order[@current_turn_index]
        @current_turn_index = (@current_turn_index + 1) % @turn_order.size
        combatant
      end

      def all_turns_complete?
        @current_turn_index == 0 && !@turn_order.empty?
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
