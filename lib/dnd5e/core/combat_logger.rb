# frozen_string_literal: true

require 'logger'
require_relative 'combat_log_formatter'

module Dnd5e
  module Core
    # Logs combat events to a logger (stdout by default).
    class CombatLogger
      include CombatLogFormatter

      def initialize(logger = Logger.new($stdout))
        @logger = logger
      end

      def update(event, data)
        case event
        when :combat_start then log_combat_start(data)
        when :round_start then log_round_start(data)
        when :turn_start then log_turn_start(data)
        when :resource_used then log_resource_used(data)
        when :combat_end then log_combat_end(data)
        when :attack_resolved then log_attack_resolved(data)
        end
      end

      private

      def log_turn_start(data)
        @logger.info "--- #{data[:combatant].name}'s Turn ---"
      end

      def log_resource_used(data)
        resource_name = data[:resource].to_s.split('_').map(&:capitalize).join(' ')
        @logger.info "[RESOURCE] #{data[:combatant].name} used #{resource_name}!"
      end

      def log_combat_start(data)
        descriptions = data[:combatants].map { |c| combatant_description(c) }.join(', ')
        @logger.info "Combat begins between #{descriptions}"
      end

      def combatant_description(combatant)
        return combatant.name unless combatant.respond_to?(:strategy)

        strategy = combatant.strategy
        return combatant.name unless strategy.respond_to?(:name)

        "#{combatant.name} [#{strategy.name}]"
      end

      def log_round_start(data)
        @logger.debug "Round: #{data[:round]}"
      end

      def log_combat_end(data)
        @logger.info 'Combat Over'
        winner_name = data[:winner] ? data[:winner].name : 'None'
        @logger.info "Winner: #{winner_name}"
        return unless data[:initiative_winner]

        winner = data[:initiative_winner]
        name = winner.respond_to?(:name) ? winner.name : winner.to_s
        @logger.info "Initiative Winner: #{name}"
      end

      def log_attack_resolved(data)
        result = data[:result]
        if result.type == :save
          log_save_resolution(result)
        else
          log_attack_roll_resolution(result)
        end

        log_damage_and_defeat(result)
      end

      def log_save_resolution(result)
        msg = "#{result.defender.name} rolled a save against #{result.attack.name} of #{result.save_roll} " \
              "#{format_roll_info(result)} against DC #{result.save_dc}"
        @logger.debug msg

        # Attacker success means Save Fail
        status = result.success ? 'fails' : 'succeeds on'
        msg2 = "#{result.defender.name} #{status} #{result.attack.save_ability} save against #{result.attack.name}!"
        @logger.info msg2
      end

      def log_attack_roll_resolution(result)
        roll_info = format_roll_info(result)
        msg = "Attacker #{result.attacker.name} uses #{result.attack.name} and rolls " \
              "#{result.attack_roll} #{roll_info}"
        @logger.debug msg

        return log_missing_ac(result) if result.target_ac.nil?

        if result.success
          log_attack_hit(result)
        else
          log_attack_miss(result)
        end
      end

      def log_missing_ac(result)
        @logger.warn "#{result.defender.name} has no armor class!"
      end

      def log_attack_hit(result)
        roll_info = format_damage_info(result)
        hp_info = "| #{result.defender.name} HP: #{result.current_hp}/#{result.max_hp}"
        @logger.info "#{result.attacker.name} hits #{result.defender.name} with #{result.attack.name} " \
                     "for #{result.damage} damage! #{roll_info} #{hp_info}"
      end

      def log_attack_miss(result)
        @logger.info "#{result.attacker.name} misses #{result.defender.name} with #{result.attack.name}!"
      end

      def log_damage_and_defeat(result)
        log_damage(result) if result.damage.positive?
        log_no_damage(result) if result.damage.zero? && result.type == :save
        @logger.info "[DEFEATED] #{result.defender.name} has been defeated!" if result.is_dead
      end

      def log_damage(result)
        return unless result.type == :save

        roll_info = format_damage_info(result)
        @logger.info "#{result.defender.name} takes #{result.damage} damage! #{roll_info}"
      end

      def log_no_damage(result)
        @logger.info "#{result.defender.name} takes no damage."
      end
    end
  end
end
