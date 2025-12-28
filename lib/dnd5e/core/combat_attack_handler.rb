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

      def attack(attacker, defender, **options)
        raise InvalidAttackError, 'Cannot attack with a dead attacker' unless attacker.statblock.alive?
        raise InvalidAttackError, 'Cannot attack a dead defender' unless defender.statblock.alive?

        attack_to_use = options[:attack] || attacker.attacks.first

        if attack_to_use.area_radius
          resolve_aoe(attacker, defender, attack_to_use, **options)
        else
          @attack_resolver.resolve(attacker, defender, attack_to_use, **options)
        end
      end

      private

      def resolve_aoe(attacker, target, attack, **options)
        combat = options[:combat]
        return @attack_resolver.resolve(attacker, target, attack, **options) unless combat

        # Identify victims: In our simple 1D engine, AOE hits the target side
        # and potentially the attacker's side if distance is small.
        victims = find_aoe_victims(attacker, target, attack, combat)

        victims.map do |victim|
          @attack_resolver.resolve(attacker, victim, attack, **options)
        end
      end

      def find_aoe_victims(_attacker, target, attack, combat)
        radius = attack.area_radius

        # If distance between side is less than radius, everyone is hit!
        # Otherwise, only the target's side is hit.
        if combat.distance < radius
          combat.combatants.select { |c| c.statblock.alive? }
        else
          # Only hit target's team
          target_team = target.team || combat.teams.find { |t| t.members.include?(target) }
          target_team.alive_members
        end
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
