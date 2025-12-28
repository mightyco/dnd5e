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
        when :combat_start
          log_combat_start(data)
        when :round_start
          log_round_start(data)
        when :combat_end
          log_combat_end(data)
        when :attack_resolved
          log_attack_resolved(data)
        end
      end

      private

      def log_combat_start(data)
        names = data[:combatants].map(&:name).join(', ')
        @logger.info "Combat begins between #{names}"
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
        msg = "#{result.defender.name} rolled a save of #{result.save_roll} " \
              "#{format_roll_info(result)} against DC #{result.save_dc}"
        @logger.debug msg

        # Attacker success means Save Fail
        if result.success
          log_save_failure(result)
        else
          log_save_success(result)
        end
      end

      def log_save_failure(result)
        @logger.info "#{result.defender.name} fails #{result.attack.save_ability} save against #{result.attacker.name}!"
      end

      def log_save_success(result)
        msg = "#{result.defender.name} succeeds on #{result.attack.save_ability} save against #{result.attacker.name}!"
        @logger.info msg
      end

      def log_attack_roll_resolution(result)
        roll_info = format_roll_info(result)
        msg = "Attacker #{result.attacker.name} rolled an attack roll of #{result.attack_roll} #{roll_info}"
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
        @logger.info "#{result.attacker.name} hits #{result.defender.name} for #{result.damage} damage! #{roll_info}"
      end

      def log_attack_miss(result)
        @logger.info "#{result.attacker.name} misses #{result.defender.name}!"
      end

      def log_damage_and_defeat(result)
        log_damage(result) if result.damage.positive?
        log_no_damage(result) if result.damage.zero? && result.type == :save
        @logger.info "#{result.defender.name} is defeated!" if result.is_dead
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
