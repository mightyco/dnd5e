# frozen_string_literal: true

require_relative 'dice'
require_relative 'dice_roller'
require_relative 'turn_manager'
require_relative 'attack_resolver'
require_relative 'combat_attack_handler'
require_relative 'publisher'
require_relative 'tactical_grid'
require_relative 'point_2d'
require 'logger'

module Dnd5e
  module Core
    class InvalidAttackError < StandardError; end
    class InvalidWinnerError < StandardError; end
    class CombatTimeoutError < StandardError; end

    # Manages combat preparation and conclusion.
    module CombatLifecycle
      private

      def prepare_combat
        @turn_manager.roll_initiative
        @turn_manager.sort_by_initiative
        @round_counter = 1
        notify_observers(:combat_start, combat: self, combatants: @combatants)
        notify_observers(:round_start, round: @round_counter)
      end

      def conclude_combat
        init_winner = @turn_manager.turn_order.first
        begin
          notify_observers(:combat_end, winner: winner, initiative_winner: init_winner, combatants: @combatants)
        rescue InvalidWinnerError
          notify_observers(:combat_end, winner: nil, initiative_winner: init_winner, combatants: @combatants)
        end
      end
    end

    # Manages spatial queries and movement for Combat.
    module CombatSpatial
      private

      def grid_distance(comb1, comb2)
        @grid.distance(comb1, comb2, a_alt: comb1.statblock.altitude, b_alt: comb2.statblock.altitude)
      end

      def find_primary_combatants
        c1 = @combatants.first
        c2 = @combatants.find { |c| c != c1 && (c.team.nil? || c.team != c1.team) } || @combatants.last
        [c1, c2]
      end

      def calc_grid_distance(comb1, comb2)
        d = grid_distance(comb1, comb2)
        d == 999_999 ? 30 : d
      end

      def check_opportunity_attacks(mover, new_pos)
        old_pos = @grid.find_position(mover)
        return unless old_pos

        (combatants - [mover]).each do |enemy|
          next unless enemy.statblock.alive? && enemy.turn_context.reactions_used.zero?

          enemy_pos = @grid.find_position(enemy)
          trigger_opportunity_attack(enemy, mover) if leaving_threatened_zone?(old_pos, new_pos, enemy_pos)
        end
      end

      def leaving_threatened_zone?(old_pos, new_pos, enemy_pos)
        return false unless enemy_pos

        @grid.distance(old_pos, enemy_pos) <= 5 && @grid.distance(new_pos, enemy_pos) > 5
      end
    end

    # Manages the flow of a combat encounter.
    class Combat
      include Publisher
      include CombatLifecycle
      include CombatSpatial

      attr_accessor :dice_roller
      attr_reader :combatants, :turn_manager, :max_rounds, :combat_attack_handler, :grid

      def initialize(combatants:, dice_roller: DiceRoller.new, max_rounds: 1000, distance: 30)
        @combatants = combatants
        @turn_manager = TurnManager.new(combatants: @combatants)
        @dice_roller = dice_roller
        @max_rounds = max_rounds
        @round_counter = 0
        @combat_attack_handler = CombatAttackHandler.new(logger: Logger.new(nil))
        @grid = TacticalGrid.new
        setup_stationary_grid(distance)
      end

      def distance
        return 0 if @combatants.empty?

        c1, c2 = find_primary_combatants
        c1 == c2 ? 0 : calc_grid_distance(c1, c2)
      end

      def distance=(val)
        @grid.occupants.clear
        setup_stationary_grid(val)
      end

      def attack(attacker, defender, **options)
        notify_observers(:attack, attacker: attacker, defender: defender)
        options[:combat] ||= self
        options[:distance] ||= grid_distance(attacker, defender)
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

      def move_combatant(combatant, val)
        new_pos = val.is_a?(Integer) ? Point2D.new(val, 0) : val
        check_opportunity_attacks(combatant, new_pos)
        @grid.move(combatant, new_pos)
      end

      def over?
        @combatants.count { |c| c.statblock.alive? } <= 1
      end

      def winner
        alive = @combatants.select { |c| c.statblock.alive? }
        raise InvalidWinnerError, 'No winner found' if alive.empty?
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

      def setup_stationary_grid(dist)
        return unless @grid.occupants.empty?

        mid = [@combatants.size / 2, 1].max
        @combatants.uniq.each_with_index do |c, i|
          pos = i < mid ? Point2D.new(0, 0) : Point2D.new(dist, 0)
          @grid.place(c, pos)
        end
      end

      def run_rounds
        until over?
          current = @turn_manager.next_turn
          take_turn(current) if current.statblock.alive? && !over?
          check_round_end
          check_timeout
        end
      end

      def check_round_end
        return unless @turn_manager.all_turns_complete?

        notify_observers(:round_end, round: @round_counter)
        @round_counter += 1
        notify_observers(:round_start, round: @round_counter) unless over?
      end

      def check_timeout
        raise CombatTimeoutError, "Timed out after #{@max_rounds}" if @round_counter >= @max_rounds
      end

      def trigger_opportunity_attack(attacker, defender)
        attack(attacker, defender)
        attacker.turn_context.use_reaction
      end
    end
  end
end
