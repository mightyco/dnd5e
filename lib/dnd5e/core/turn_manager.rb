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

        sort_by_initiative if @turn_order.empty?
        cleanup_previous_turn

        combatant = @turn_order[@current_turn_index]
        combatant.start_turn if combatant.respond_to?(:start_turn)

        @current_turn_index = (@current_turn_index + 1) % @turn_order.size
        combatant
      end

      def cleanup_previous_turn
        prev_idx = (@current_turn_index - 1) % @turn_order.size
        prev_combatant = @turn_order[prev_idx]
        return unless prev_combatant

        prev_combatant.statblock.condition_manager.end_turn
      end

      def all_turns_complete?
        @current_turn_index.zero? && @turn_order.size.positive?
      end

      def acted_this_round?(combatant)
        idx = @turn_order.index(combatant)
        return false unless idx

        # If current_turn_index is 0 but turn_order is full, we might be at the start of a round
        # or end. In next_turn, we increment index after returning.
        # So if current_turn_index is 1, the 0th combatant has acted.
        idx < @current_turn_index - 1
      end

      private

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
