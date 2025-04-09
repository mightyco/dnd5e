require_relative "dice"
require_relative "dice_roller"
require_relative "turn_manager"
require 'logger'

module Dnd5e
  module Core
    class InvalidAttackError < StandardError; end
    class InvalidWinnerError < StandardError; end
    class CombatTimeoutError < StandardError; end

    # Manages the flow of a combat encounter.
    class Combat
      attr_reader :combatants, :turn_manager, :logger, :dice_roller, :max_rounds
      attr_writer :dice_roller

      # Initializes a new Combat instance.
      #
      # @param combatants [Array<Combatant>] The combatants participating in the combat.
      # @param logger [Logger] The logger to use for logging.
      # @param dice_roller [DiceRoller] The dice roller to use for rolling dice.
      # @param max_rounds [Integer] The maximum number of rounds the combat can last.
      def initialize(combatants:, logger: Logger.new($stdout), dice_roller: DiceRoller.new, max_rounds: 1000)
        @combatants = combatants
        @turn_manager = TurnManager.new(combatants: @combatants)
        @logger = logger
        @dice_roller = dice_roller
        @max_rounds = max_rounds
        @round_counter = 0
        @logger.formatter = proc do |severity, datetime, progname, msg|
          "#{msg}\n"
        end
      end

      # Performs an attack from an attacker to a defender.
      #
      # @param attacker [Combatant] The attacking combatant.
      # @param defender [Combatant] The defending combatant.
      # @raise [InvalidAttackError] if the attacker or defender is dead.
      # @return [Boolean] true if the attack hits, false otherwise.
      def attack(attacker, defender)
        raise InvalidAttackError, "Cannot attack with a dead attacker" unless attacker.statblock.is_alive?
        raise InvalidAttackError, "Cannot attack a dead defender" unless defender.statblock.is_alive?

        attack_dice = Dice.new(1, 20, modifier: attacker.statblock.ability_modifier(attacker.attacks.first.relevant_stat))
        attack_roll = attacker.attacks.first.dice_roller.roll_with_dice(attack_dice)
        logger.debug("Attacker #{attacker.name} rolled an attack roll of #{attack_roll}")
        if defender.statblock.armor_class.nil?
          logger.warn "#{defender.name} has no armor class!"
          return false
        end
        if attack_roll >= defender.statblock.armor_class
          damage = attacker.attacks.first.dice_roller.roll_with_dice(attacker.attacks.first.damage_dice)
          defender.statblock.take_damage(damage)
          logger.info "#{attacker.name} hits #{defender.name} for #{damage} damage!"
          logger.info "#{defender.name} is defeated!" unless defender.statblock.is_alive?
          true
        else
          logger.info "#{attacker.name} misses #{defender.name}!"
          false
        end
      end

      # Takes a turn for a given attacker.
      #
      # @param attacker [Combatant] The combatant taking the turn.
      # @return [Combatant, nil] The defender if the defender is alive, nil otherwise.
      def take_turn(attacker)
        defender = find_valid_defender(attacker)
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
          return @combatants.first
        elsif @combatants.last.statblock.is_alive? && !@combatants.first.statblock.is_alive?
          return @combatants.last
        else
          raise InvalidWinnerError, "No winner found"
        end
      end

      # Runs the combat until it is over or times out.
      #
      # @raise [CombatTimeoutError] if the combat exceeds the maximum number of rounds.
      def run_combat
        @turn_manager.roll_initiative
        @turn_manager.sort_by_initiative
        @round_counter = 1
        logger.info "Combat begins between #{@combatants.map(&:name).join(", ")}"
        logger.debug "Round: #{@round_counter}"
        until is_over?
          current_combatant = @turn_manager.next_turn
          take_turn(current_combatant) if current_combatant.statblock.is_alive? && !is_over?
          if @turn_manager.all_turns_complete?
            @round_counter += 1
            logger.debug "Round: #{@round_counter}"
          end
          raise CombatTimeoutError, "Combat timed out after #{@max_rounds} rounds" unless @round_counter < @max_rounds
        end
      end

      private

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
