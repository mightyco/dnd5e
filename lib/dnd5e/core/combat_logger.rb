# frozen_string_literal: true

require 'logger'

module Dnd5e
  module Core
    # Logs combat events to a logger (stdout by default).
    class CombatLogger
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
        @logger.debug "#{result.defender.name} rolled a save of #{result.save_roll} against DC #{result.save_dc}"

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
        @logger.debug "Attacker #{result.attacker.name} rolled an attack roll of #{result.attack_roll}"

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
        @logger.info "#{result.attacker.name} hits #{result.defender.name} for #{result.damage} damage!"
      end

      def log_attack_miss(result)
        @logger.info "#{result.attacker.name} misses #{result.defender.name}!"
      end

      def log_damage_and_defeat(result)
        # Common damage/defeat logging
        if result.damage.positive?
          @logger.info "#{result.defender.name} takes #{result.damage} damage!" if result.type == :save
          # For attack rolls, damage is usually part of the "hits" message, but checking if we need extra
        elsif result.type == :save
          @logger.info "#{result.defender.name} takes no damage."
        end

        @logger.info "#{result.defender.name} is defeated!" if result.is_dead
      end
    end
  end
end
