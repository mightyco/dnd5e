# frozen_string_literal: true

require_relative 'attack_resolver'

module Dnd5e
  module Core
    class InvalidAttackError < StandardError; end
    class InvalidWinnerError < StandardError; end

    # Handles the logic of resolving an attack in combat.
    class CombatAttackHandler
      attr_reader :logger, :attack_resolver

      # Initializes a new CombatAttackHandler instance.
      #
      # @param logger [Logger] The logger to use for logging.
      def initialize(logger: Logger.new($stdout), attack_resolver: nil)
        @logger = logger
        return unless attack_resolver.nil?

        @attack_resolver = AttackResolver.new(logger: @logger)
      end

      # Performs an attack from an attacker to a defender.
      #
      # @param attacker [Combatant] The attacking combatant.
      # @param defender [Combatant] The defending combatant.
      # @raise [InvalidAttackError] if the attacker or defender is dead.
      # @return [Boolean] true if the attack hits, false otherwise.
      def attack(attacker, defender)
        raise InvalidAttackError, 'Cannot attack with a dead attacker' unless attacker.statblock.alive?
        raise InvalidAttackError, 'Cannot attack a dead defender' unless defender.statblock.alive?

        @attack_resolver.resolve(attacker, defender, attacker.attacks.first)
      end

      # Finds a valid defender for the given attacker.
      #
      # @param attacker [Combatant] The attacking combatant.
      # @param combatants [Array<Combatant>] All combatants in the combat.
      # @return [Combatant, nil] A valid defender if one exists, nil otherwise.
      def find_valid_defender(attacker, combatants)
        (combatants - [attacker]).find { |c| c.statblock.alive? }
      end
    end
  end
end
