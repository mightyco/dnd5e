# frozen_string_literal: true

require 'logger'

module Dnd5e
  module Core
    class CombatLogger
      def initialize(logger = Logger.new($stdout))
        @logger = logger
      end

      def update(event, data)
        case event
        when :combat_start
          names = data[:combatants].map(&:name).join(', ')
          @logger.info "Combat begins between #{names}"
        when :round_start
          @logger.debug "Round: #{data[:round]}"
        when :combat_end
          @logger.info 'Combat Over'
          winner_name = data[:winner] ? data[:winner].name : 'None'
          @logger.info "Winner: #{winner_name}"
          if data[:initiative_winner]
            # Check if initiative_winner is a Team or Combatant.
            # If it's a Combatant, it has .team method?
            # In TeamCombat, initiative_winner passed was @turn_manager.turn_order.first.team
            # In Combat, I passed @turn_manager.turn_order.first (Combatant).
            # So I need to handle both or standardize.
            # For printing, name is sufficient.
            name = data[:initiative_winner].respond_to?(:name) ? data[:initiative_winner].name : data[:initiative_winner].to_s
            @logger.info "Initiative Winner: #{name}"
          end
        when :attack_resolved
          result = data[:result]
          if result.type == :save
            # Save resolution
            @logger.debug "#{result.defender.name} rolled a save of #{result.save_roll} against DC #{result.save_dc}"

            # Attacker success means Save Fail
            if result.success
              @logger.info "#{result.defender.name} fails #{result.attack.save_ability} save against #{result.attacker.name}!"
            else
              @logger.info "#{result.defender.name} succeeds on #{result.attack.save_ability} save against #{result.attacker.name}!"
            end

          else
            # Attack roll resolution
            @logger.debug "Attacker #{result.attacker.name} rolled an attack roll of #{result.attack_roll}"

            if result.target_ac.nil?
              @logger.warn "#{result.defender.name} has no armor class!"
            elsif result.success
              @logger.info "#{result.attacker.name} hits #{result.defender.name} for #{result.damage} damage!"
            else
              @logger.info "#{result.attacker.name} misses #{result.defender.name}!"
            end
          end

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
end
