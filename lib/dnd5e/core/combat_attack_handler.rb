require_relative "dice"
require_relative "dice_roller"
require_relative "attack_resolver"

module Dnd5e
  module Core
    # Handles the logic of resolving an attack in combat.
    class CombatAttackHandler
      def initialize(logger: Logger.new($stdout), attack_resolver: AttackResolver.new(logger: Logger.new($stdout)))
        @logger = logger
        @attack_resolver = attack_resolver
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

        @attack_resolver.resolve(attacker, defender, attacker.attacks.first)
      end
    end
  end
end
