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

      attr_accessor :dice_roller, :distance
      attr_reader :combatants, :turn_manager, :max_rounds, :combat_attack_handler

      def initialize(combatants:, dice_roller: DiceRoller.new, max_rounds: 1000, distance: 30)
        @combatants = combatants
        @turn_manager = TurnManager.new(combatants: @combatants)
        @dice_roller = dice_roller
        @max_rounds = max_rounds
        @round_counter = 0
        @distance = distance
        @combat_attack_handler = CombatAttackHandler.new(logger: Logger.new(nil))
      end

      def attack(attacker, defender, **options)
        notify_observers(:attack, attacker: attacker, defender: defender)
        options[:combat] ||= self
        results = @combat_attack_handler.attack(attacker, defender, **options)

        Array(results).each { |r| notify_observers(:attack_resolved, result: r) }
        results
      end

      def take_turn(attacker)
        notify_observers(:turn_start, combatant: attacker)

        if attacker.respond_to?(:strategy)
          attacker.strategy.execute_turn(attacker, self)
        else
          defender = find_valid_defender(attacker)
          attack(attacker, defender) if defender
        end
      end

      def move_combatant(combatant, new_distance)
        check_opportunity_attacks(combatant, new_distance)
        @distance = new_distance
      end

      def over?
        alive_combatants = @combatants.select { |c| c.statblock.alive? }
        alive_combatants.size <= 1
      end

      def winner
        alive = @combatants.select { |c| c.statblock.alive? }
        raise InvalidWinnerError, 'No winner found (all dead)' if alive.empty?
        raise InvalidWinnerError, 'Combat not over' if alive.size > 1

        alive.first
      end

      def run_combat
        prepare_combat
        run_rounds
        conclude_combat
      end

      def find_valid_defender(attacker)
        (combatants - [attacker]).find { |c| c.statblock.alive? }
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
        until over?
          process_turn
          check_round_end
          check_timeout
        end
      end

      def process_turn
        current = @turn_manager.next_turn
        take_turn(current) if current.statblock.alive? && !over?
      end

      def check_round_end
        return unless @turn_manager.all_turns_complete?

        notify_observers(:round_end, round: @round_counter)
        @round_counter += 1
        notify_observers(:round_start, round: @round_counter) unless over?
      end

      def check_timeout
        return if @round_counter < @max_rounds

        raise CombatTimeoutError, "Combat timed out after #{@max_rounds} rounds"
      end

      def conclude_combat
        init_winner = @turn_manager.turn_order.first
        begin
          notify_observers(:combat_end, winner: winner, initiative_winner: init_winner)
        rescue InvalidWinnerError
          notify_observers(:combat_end, winner: nil, initiative_winner: init_winner)
        end
      end

      def check_opportunity_attacks(mover, new_dist)
        return unless @distance == 5 && new_dist > 5

        enemies = combatants - [mover]
        enemies.select { |e| e.statblock.alive? && e.turn_context.reactions_used.zero? }.each do |enemy|
          trigger_opportunity_attack(enemy, mover)
        end
      end

      def trigger_opportunity_attack(attacker, defender)
        attack(attacker, defender)
        attacker.turn_context.use_reaction
      end
    end
  end
end
