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

        context = { attacker: attacker, target: target, attack: attack, options: options, combat: combat }
        victims = attacker.feature_manager.apply_hook(:on_aoe_target_selection, context, victims)

        victims.map do |victim|
          @attack_resolver.resolve(attacker, victim, attack, **options)
        end
      end

      def find_aoe_victims(_attacker, target, attack, combat)
        radius = attack.area_radius

        if combat.respond_to?(:grid)
          target_pos = combat.grid.find_position(target)
          return combat.grid.combatants_within(target_pos, radius) if target_pos
        end

        fallback_aoe_victims(target, radius, combat)
      end

      def fallback_aoe_victims(target, radius, combat)
        if combat.distance < radius
          combat.combatants.select { |c| c.statblock.alive? }
        else
          target_team = target.team || combat.teams.find { |t| t.members.include?(target) }
          target_team.respond_to?(:alive_members) ? target_team.alive_members : []
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
