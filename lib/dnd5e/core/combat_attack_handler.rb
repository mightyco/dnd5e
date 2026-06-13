# frozen_string_literal: true

require_relative 'attack_resolver'

module Dnd5e
  module Core
    # Handles the orchestration of an attack.
    class CombatAttackHandler
      attr_reader :logger, :attack_resolver

      # Initializes a new CombatAttackHandler.
      #
      # @param logger [Logger] The logger to use for logging.
      def initialize(logger: Logger.new($stdout), attack_resolver: nil)
        @logger = logger
        @attack_resolver = attack_resolver || AttackResolver.new(logger: @logger)
      end

      def attack(attacker, defender, **options)
        return unless attacker.statblock.alive?
        return unless defender&.statblock&.alive?

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

        # Identify victims using grid if available
        victims = find_aoe_victims(attacker, target, attack, combat)

        victims.map do |victim|
          @attack_resolver.resolve(attacker, victim, attack, **options)
        end
      end

      def find_aoe_victims(_attacker, target, attack, combat)
        target_pos = combat.grid.find_position(target)
        return [target] unless target_pos

        combat.combatants.select do |c|
          next unless c.statblock.alive?

          c_pos = combat.grid.find_position(c)
          c_pos && combat.grid.distance(target_pos, c_pos) <= attack.area_radius
        end
      end
    end
  end
end
