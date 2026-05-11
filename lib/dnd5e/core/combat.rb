# frozen_string_literal: true

require_relative 'dice'
require_relative 'dice_roller'
require_relative 'turn_manager'
require_relative 'attack_resolver'
require_relative 'combat_attack_handler'
require_relative 'publisher'
require_relative 'tactical_grid'

module Dnd5e
  module Core
    class CombatTimeoutError < StandardError; end
    class InvalidWinnerError < StandardError; end

    # Lifecycle methods for Combat.
    module CombatLifecycle
      def over?
        # Detect teams from combatants if not explicitly set
        teams = @combatants.map { |c| c.respond_to?(:team) ? c.team : nil }.compact.uniq
        return @combatants.count { |c| c.statblock.alive? } <= 1 if teams.empty?

        teams.count { |team| !team.all_members_defeated? } <= 1
      end

      def winner
        teams = @combatants.map { |c| c.respond_to?(:team) ? c.team : nil }.compact.uniq
        w = teams.empty? ? @combatants.find { |c| c.statblock.alive? } : teams.reject(&:all_members_defeated?).first

        raise InvalidWinnerError, 'No winner found' if w.nil?

        w
      end

      def run_combat
        notify_observers(:combat_start, combat: self, combatants: @combatants)
        prepare_combat
        run_rounds
        finalize_combat
      end

      def prepare_combat
        @turn_manager.roll_initiative
        @turn_manager.sort_by_initiative
      end

      def finalize_combat
        init_winner = @turn_manager.turn_order.first
        begin
          w = winner
          notify_observers(:combat_end, winner: w, initiative_winner: init_winner, combatants: @combatants)
        rescue InvalidWinnerError
          notify_observers(:combat_end, winner: nil, initiative_winner: init_winner, combatants: @combatants)
        end
        winner
      rescue InvalidWinnerError
        nil
      end

      def run_rounds
        notify_observers(:round_start, round: @round_counter)
        until over?
          check_timeout
          process_turn_cycle
        end
      end

      def process_turn_cycle
        loop do
          combatant = @turn_manager.next_turn
          take_turn(combatant) if combatant.statblock.alive?
          break if over? || @turn_manager.all_turns_complete?
        end
        increment_round
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

        (combatants - [mover]).each do |attacker|
          next unless valid_opportunity_attacker?(attacker, mover)

          enemy_pos = @grid.find_position(attacker)
          trigger_opportunity_attack(attacker, mover) if leaving_threatened_zone?(old_pos, new_pos, enemy_pos)
        end
      end

      def valid_opportunity_attacker?(attacker, mover)
        attacker.statblock.alive? &&
          attacker.turn_context.reactions_used.zero? &&
          enemy?(attacker, mover) &&
          melee_reach?(attacker)
      end

      def melee_reach?(combatant)
        combatant.attacks.any? { |a| !a.properties.include?(:ranged) && a.range <= 10 }
      end

      def leaving_threatened_zone?(old_pos, new_pos, enemy_pos)
        return false unless enemy_pos

        # Old standard reach is 5ft
        old_dist = @grid.distance(old_pos, enemy_pos)
        new_dist = @grid.distance(new_pos, enemy_pos)

        old_dist <= 5 && new_dist > 5
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
        @turn_manager = TurnManager.new(combatants: @combatants, dice_roller: dice_roller)
        @dice_roller = dice_roller
        @max_rounds = max_rounds
        @round_counter = 1
        @combat_attack_handler = CombatAttackHandler.new(logger: Logger.new(nil))
        @grid = TacticalGrid.new
        setup_stationary_grid(distance)
      end

      def find_valid_defender(attacker)
        potential = @combatants.select do |c|
          c.statblock.alive? && c != attacker && enemy?(attacker, c)
        end
        potential.min_by { |c| c.statblock.hit_points }
      end

      def distance
        return 0 if @combatants.size < 2

        comb1, comb2 = find_primary_combatants
        calc_grid_distance(comb1, comb2)
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
        attacker.strategy.execute_turn(attacker, self)
      end

      def move_combatant(combatant, path)
        Array(path).each do |step_pos|
          execute_move_step(combatant, step_pos)
        end
      end

      def enemy?(comb1, comb2)
        team1 = comb1.respond_to?(:team) ? comb1.team : comb1.instance_variable_get(:@team)
        team2 = comb2.respond_to?(:team) ? comb2.team : comb2.instance_variable_get(:@team)
        return true if team1.nil? || team2.nil?

        n1 = team1.respond_to?(:name) ? team1.name : team1.to_s
        n2 = team2.respond_to?(:name) ? team2.name : team2.to_s
        n1 != n2
      end

      def execute_move_step(combatant, step_pos)
        old_pos = @grid.find_position(combatant)
        check_opportunity_attacks(combatant, step_pos) if old_pos
        @grid.move(combatant, step_pos)
        notify_observers(:move_resolved, combatant: combatant, from: old_pos, to: step_pos)
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
