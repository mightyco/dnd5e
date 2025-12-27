# frozen_string_literal: true

require_relative 'dice'
require_relative 'dice_roller'
require_relative 'turn_manager'
require_relative 'attack_resolver'
require_relative 'combat_attack_handler'
require_relative 'publisher'
require 'logger'

module Dnd5e
  module Core
    class InvalidAttackError < StandardError; end
    class InvalidWinnerError < StandardError; end
    class CombatTimeoutError < StandardError; end

    # Manages the flow of a combat encounter.
    class Combat
      include Publisher
      attr_accessor :dice_roller
      attr_reader :combatants, :turn_manager, :max_rounds, :combat_attack_handler

      # Initializes a new Combat instance.
      #
      # @param combatants [Array<Combatant>] The combatants participating in the combat.
      # @param dice_roller [DiceRoller] The dice roller to use for rolling dice.
      # @param max_rounds [Integer] The maximum number of rounds the combat can last.
      def initialize(combatants:, dice_roller: DiceRoller.new, max_rounds: 1000)
        @combatants = combatants
        @turn_manager = TurnManager.new(combatants: @combatants)
        @dice_roller = dice_roller
        @max_rounds = max_rounds
        @round_counter = 0
        @combat_attack_handler = CombatAttackHandler.new(logger: Logger.new(nil)) # Use silent logger
      end

      # Performs an attack from an attacker to a defender.
      #
      # @param attacker [Combatant] The attacking combatant.
      # @param defender [Combatant] The defending combatant.
      # @raise [InvalidAttackError] if the attacker or defender is dead.
      # @return [Boolean] true if the attack hits/succeeds, false otherwise.
      def attack(attacker, defender)
        notify_observers(:attack, attacker: attacker, defender: defender)
        result = @combat_attack_handler.attack(attacker, defender)
        notify_observers(:attack_resolved, result: result)
        result.success
      end

      # Takes a turn for a given attacker.
      #
      # @param attacker [Combatant] The combatant taking the turn.
      # @return [Combatant, nil] The defender if the defender is alive, nil otherwise.
      def take_turn(attacker)
        notify_observers(:turn_start, combatant: attacker)
        defender = find_valid_defender(attacker)
        if defender.nil?
          # logger.info "No valid targets for #{attacker.name}, skipping turn" # Deprecated
          return false
        end

        begin
          attack(attacker, defender)
        rescue InvalidAttackError
          # logger.info "Skipping turn: #{e.message}" # Deprecated
        end
        defender.statblock.is_alive? ? defender : nil
      end

      # Checks if the combat is over.
      #
      # @return [Boolean] true if the combat is over, false otherwise.
      def is_over?
        return true if @combatants.any? { |c| !c.statblock.is_alive? }

        false
      end

      # Determines the winner of the combat.
      #
      # @raise [InvalidWinnerError] if no winner can be determined.
      # @return [Combatant] The winning combatant.
      def winner
        if @combatants.first.statblock.is_alive? && !@combatants.last.statblock.is_alive?
          @combatants.first
        elsif @combatants.last.statblock.is_alive? && !@combatants.first.statblock.is_alive?
          @combatants.last
        else
          raise InvalidWinnerError, 'No winner found'
        end
      end

      # Runs the combat until it is over or times out.
      #
      # @raise [CombatTimeoutError] if the combat exceeds the maximum number of rounds.
      def run_combat
        prepare_combat
        run_rounds
        conclude_combat
      end

      private

      def prepare_combat
        @turn_manager.roll_initiative
        @turn_manager.sort_by_initiative
        @round_counter = 1
        notify_observers(:combat_start, combat: self, combatants: @combatants)
        notify_observers(:round_start, round: @round_counter)
      end

      def run_rounds
        until is_over?
          process_turn
          check_round_end
          check_timeout
        end
      end

      def process_turn
        current_combatant = @turn_manager.next_turn
        return unless current_combatant.statblock.is_alive? && !is_over?

        take_turn(current_combatant)
      end

      def check_round_end
        return unless @turn_manager.all_turns_complete?

        notify_observers(:round_end, round: @round_counter)
        @round_counter += 1
        notify_observers(:round_start, round: @round_counter) unless is_over?
      end

      def check_timeout
        return if @round_counter < @max_rounds

        raise CombatTimeoutError, "Combat timed out after #{@max_rounds} rounds"
      end

      def conclude_combat
        initiative_winner = @turn_manager.turn_order.first
        begin
          notify_observers(:combat_end, winner: winner, initiative_winner: initiative_winner)
        rescue InvalidWinnerError
          notify_observers(:combat_end, winner: nil, initiative_winner: initiative_winner)
        end
      end

      # Finds a valid defender for the given attacker.
      #
      # @param attacker [Combatant] The attacking combatant.
      # @return [Combatant, nil] A valid defender if one exists, nil otherwise.
      def find_valid_defender(attacker)
        (combatants - [attacker]).find { |c| c.statblock.is_alive? }
      end
    end
  end
end
