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

      def run_rounds
        until over?
          process_turn_cycle
          check_timeout
        end
      end

      def process_turn_cycle
        current = @turn_manager.next_turn
        take_turn(current) if current.statblock.alive? && !over?
        increment_round if @turn_manager.all_turns_complete?
      end

      def increment_round
        notify_observers(:round_end, round: @round_counter)
        @round_counter += 1
        notify_observers(:round_start, round: @round_counter) unless over?
      end
    end

    # Manages spatial queries and movement for Combat.
    module CombatSpatial
      private

      def grid_distance(comb1, comb2)
        @grid.distance(comb1, comb2, a_alt: comb1.statblock.altitude, b_alt: comb2.statblock.altitude)
      end

      def find_primary_combatants
        return [@combatants[0], @combatants[0]] if @combatants.size < 2

        [@combatants[0], @combatants[1]]
      end

      def calc_grid_distance(comb1, comb2)
        d = grid_distance(comb1, comb2)
        d == 999_999 ? 30 : d
      end

      def check_opportunity_attacks(mover, new_pos)
        old_pos = @grid.find_position(mover)
        return unless old_pos

        (combatants - [mover]).each do |potential_attacker|
          next unless potential_attacker.statblock.alive? &&
                      potential_attacker.turn_context.reactions_used.zero? &&
                      enemy?(potential_attacker, mover)

          enemy_pos = @grid.find_position(potential_attacker)
          trigger_opportunity_attack(potential_attacker, mover) if leaving_threatened_zone?(old_pos, new_pos, enemy_pos)
        end
      end

      def leaving_threatened_zone?(old_pos, new_pos, enemy_pos)
        return false unless enemy_pos

        @grid.distance(old_pos, enemy_pos) <= 5 && @grid.distance(new_pos, enemy_pos) > 5
      end

      def pos_from_value(val)
        val.is_a?(Integer) ? Point2D.new(val, 0) : val
      end

      def setup_stationary_grid(dist)
        @combatants.each { |c| @grid.remove(c) }
        mid = [@combatants.size / 2, 1].max
        @combatants.uniq.each_with_index do |c, i|
          pos = i < mid ? Point2D.new(0, 0) : Point2D.new(dist, 0)
          @grid.place(c, pos)
        end
      end
    end

    # Manages the flow of a combat encounter.
    class Combat
      include Publisher
      include CombatLifecycle
      include CombatSpatial

      attr_accessor :dice_roller
      attr_reader :combatants, :turn_manager, :max_rounds, :combat_attack_handler, :grid, :round_counter

      def initialize(combatants:, dice_roller: DiceRoller.new, max_rounds: 10, distance: 30)
        @combatants = combatants
        @combatants.each { |c| c.instance_variable_set(:@combat_context, self) }
        @turn_manager = TurnManager.new(combatants: @combatants)
        @dice_roller = dice_roller
        @max_rounds = max_rounds
        @round_counter = 0
        @combat_attack_handler = CombatAttackHandler.new(logger: Logger.new(nil))
        @grid = TacticalGrid.new
        setup_stationary_grid(distance)
      end

      def distance
        return 0 if @combatants.size < 2

        c1, c2 = find_primary_combatants
        calc_grid_distance(c1, c2)
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
        notify_observers(:turn_start, combatant: attacker, combat: self)
        if attacker.respond_to?(:strategy)
          attacker.strategy.execute_turn(attacker, self)
        else
          defender = find_valid_defender(attacker)
          attack(attacker, defender) if defender
        end
      end

      def move_combatant(combatant, val)
        path = val.is_a?(Array) ? val : [pos_from_value(val)]
        path.each_with_index do |step_pos, index|
          next if index == path.size - 1 && !@grid.can_end_at?(step_pos, combatant)

          execute_move_step(combatant, step_pos)
          break unless combatant.statblock.alive?
        end
      end

      def over?
        alive = @combatants.select { |c| c.statblock.alive? }
        return true if alive.size <= 1

        first_team = alive.first.team
        return true if first_team && alive.all? { |c| c.team == first_team }

        false
      end

      def winner
        alive = @combatants.select { |c| c.statblock.alive? }
        raise InvalidWinnerError, 'No winner found' if alive.empty?

        alive.first.team || alive.first
      end

      def run_combat
        prepare_combat
        run_rounds
        conclude_combat
      end

      def find_valid_defender(attacker)
        @combatants.select { |c| c.statblock.alive? && enemy?(attacker, c) }.first
      end

      def enemy?(comb1, comb2)
        return false if comb1 == comb2

        t1 = comb1.respond_to?(:team) ? comb1.team : nil
        t2 = comb2.respond_to?(:team) ? comb2.team : nil

        # If both have teams, they are enemies only if the teams are different
        return different_teams?(t1, t2) if t1 && t2

        # Fallback: if one lacks a team, assume enemy (standard for monsters vs players)
        # unless they are explicitly the same instance
        true
      end

      private

      def different_teams?(team1, team2)
        return false unless team1 && team2

        n1 = team1.respond_to?(:name) ? team1.name : team1.to_s
        n2 = team2.respond_to?(:name) ? team2.name : team2.to_s
        n1 != n2
      end

      def execute_move_step(combatant, step_pos)
        check_opportunity_attacks(combatant, step_pos)
        @grid.move(combatant, step_pos)
        notify_observers(:move_resolved, combatant: combatant, position: step_pos)
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
