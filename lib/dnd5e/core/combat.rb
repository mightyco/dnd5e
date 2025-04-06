require_relative "dice"
require_relative "dice_roller"
require_relative "turn_manager"
require 'logger'

module Dnd5e
  module Core
    class InvalidAttackError < StandardError; end
    class InvalidWinnerError < StandardError; end
    class CombatTimeoutError < StandardError; end

    class Combat
      attr_reader :combatants, :turn_manager, :logger, :dice_roller, :max_rounds
      attr_writer :dice_roller

      def initialize(combatants:, logger: Logger.new($stdout), dice_roller: DiceRoller.new, max_rounds: 1000)
        @combatants = combatants
        @turn_manager = TurnManager.new(combatants: @combatants)
        @logger = logger
        @dice_roller = dice_roller
        @max_rounds = max_rounds
        @round_counter = 0
        logger.formatter = proc do |severity, datetime, progname, msg|
          "#{msg}\n"
        end
      end

      def attack(attacker, defender)
        raise InvalidAttackError, "Cannot attack with a dead attacker" unless attacker.statblock.is_alive?
        raise InvalidAttackError, "Cannot attack a dead defender" unless defender.statblock.is_alive?

        attack_roll = @dice_roller.roll_with_dice(Dice.new(1, 20, modifier: attacker.statblock.ability_modifier(attacker.attacks.first.relevant_stat)))
        if defender.statblock.armor_class.nil?
          logger.warn "#{defender.name} has no armor class!"
          return false
        end
        if attack_roll >= defender.statblock.armor_class
          damage = @dice_roller.roll_with_dice(attacker.attacks.first.damage_dice)
          defender.statblock.take_damage(damage)
          logger.info "#{attacker.name} hits #{defender.name} for #{damage} damage!"
          logger.info "#{defender.name} is defeated!" unless defender.statblock.is_alive?
          true
        else
          logger.info "#{attacker.name} misses #{defender.name}!"
          false
        end
      end

      def take_turn(attacker)
        defender = (combatants - [attacker]).find { |c| c.statblock.is_alive? }
        if defender.nil?
          logger.info "No valid targets for #{attacker.name}, skipping turn"
          return false
        end

        begin
          attack(attacker, defender)
        rescue InvalidAttackError => e
          logger.info "Skipping turn: #{e.message}"
        end
        defender.statblock.is_alive? ? defender : nil
      end

      def is_over?
        return true if @combatants.any? { |c| !c.statblock.is_alive? }
        false
      end

      def winner
        if @combatants.first.statblock.is_alive? && !@combatants.last.statblock.is_alive?
          return @combatants.first
        elsif @combatants.last.statblock.is_alive? && !@combatants.first.statblock.is_alive?
          return @combatants.last
        else
          raise InvalidWinnerError, "No winner found"
        end
      end

      def run_combat
        @turn_manager.roll_initiative
        @turn_manager.sort_by_initiative
        @round_counter = 1
        logger.info "Combat begins between #{@combatants.map(&:name).join(", ")}"
        until is_over?
          logger.debug "Round: #{@round_counter}"
          current_combatant = @turn_manager.next_turn
          take_turn(current_combatant) if current_combatant.statblock.is_alive? && !is_over?
          if @turn_manager.all_turns_complete?
            @round_counter += 1
          end
          raise CombatTimeoutError, "Combat timed out after #{@max_rounds} rounds" unless @round_counter < @max_rounds
        end
      end
    end
  end
end
