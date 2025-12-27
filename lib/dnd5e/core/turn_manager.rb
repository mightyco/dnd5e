# frozen_string_literal: true

require_relative 'dice'
require_relative 'dice_roller'

module Dnd5e
  module Core
    # Manages the order of turns in a combat scenario.
    class TurnManager
      # Error raised when there are no combatants in the turn manager.
      class NoCombatantsError < StandardError; end

      attr_reader :combatants, :turn_order
      attr_writer :dice_roller

      # Initializes a new TurnManager.
      #
      # @param combatants [Array<Character, Monster>] The combatants in the combat.
      # @param dice_roller [DiceRoller] The dice roller to use for initiative rolls.
      def initialize(combatants:, dice_roller: DiceRoller.new)
        @combatants = combatants
        @turn_order = []
        @current_turn_index = 0
        @dice_roller = dice_roller
      end

      # Rolls initiative for each combatant.
      def roll_initiative
        @combatants.each do |combatant|
          combatant.instance_variable_set(:@initiative,
                                          @dice_roller.roll('1d20') + combatant.statblock.ability_modifier(:dexterity))
        end
      end

      # Sorts the combatants by initiative.
      def sort_by_initiative
        @turn_order = @combatants.sort_by do |combatant|
          [-combatant.instance_variable_get(:@initiative), -combatant.statblock.ability_modifier(:dexterity)]
        end
      end

      # Returns the next combatant in the turn order.
      #
      # @return [Character, Monster] The next combatant.
      # @raise [NoCombatantsError] if there are no combatants.
      def next_turn
        raise NoCombatantsError, 'No combatants in the turn manager' if @combatants.empty?

        if @turn_order.empty?
          # Should have sorted by now, but just in case
          sort_by_initiative
        end

        combatant = @turn_order[@current_turn_index]
        @current_turn_index = (@current_turn_index + 1) % @turn_order.size
        combatant
      end

      # Checks if all turns have been completed.
      #
      # @return [Boolean] True if all turns are complete, false otherwise.
      def all_turns_complete?
        @current_turn_index.zero? && @turn_order.size.positive?
      end

      # Adds a combatant to the turn manager.
      #
      # @param combatant [Character, Monster] The combatant to add.
      def add_combatant(combatant)
        @combatants << combatant
      end

      # Removes a combatant from the turn manager.
      #
      # @param combatant [Character, Monster] The combatant to remove.
      def remove_combatant(combatant)
        @combatants.delete(combatant)
      end
    end
  end
end
