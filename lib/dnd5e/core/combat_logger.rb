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
          names = data[:combatants].map(&:name).join(", ")
          @logger.info "Combat begins between #{names}"
        when :round_start
          @logger.debug "Round: #{data[:round]}"
        when :combat_end
          @logger.info "Combat Over"
          winner_name = data[:winner] ? data[:winner].name : "None"
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
        end
      end
    end
  end
end
