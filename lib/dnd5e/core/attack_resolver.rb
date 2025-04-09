require 'logger'

module Dnd5e
  module Core
    # Resolves an attack, applying damage and logging the result.
    class AttackResolver
      def initialize(logger: Logger.new($stdout))
        @logger = logger
        logger.formatter = proc do |severity, datetime, progname, msg|
          "#{msg}\n"
        end
      end

      # Resolves an attack, applying damage and logging the result.
      #
      # @param attacker [Character] The attacking character.
      # @param defender [Character] The defending character.
      # @param attack [Attack] The attack being performed.
      def resolve(attacker, defender, attack)
        if attack.attack(attacker, defender)
          damage = attack.calculate_damage(attacker)
          defender.statblock.take_damage(damage)
          @logger.info "#{attacker.name} hits #{defender.name} for #{damage} damage!"
          @logger.info "#{defender.name} is defeated!" unless defender.statblock.is_alive?
          true
        else
          @logger.info "#{attacker.name} misses #{defender.name}!"
          false
        end
      end
    end
  end
end
