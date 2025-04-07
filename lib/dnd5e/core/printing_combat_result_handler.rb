require_relative "combat_result_handler"
require 'logger'

module Dnd5e
  module Core
    class PrintingCombatResultHandler < CombatResultHandler
      attr_reader :logger

      def initialize(logger: Logger.new($stdout))
        super()
        @logger = logger
        logger.formatter = proc do |severity, datetime, progname, msg|
          "#{msg}\n"
        end
      end

      def handle_result(combat, winner, initiative_winner)
        logger.info "Combat Over"
        logger.info "Winner: #{winner.name}"
        logger.info "Initiative Winner: #{initiative_winner.name}"
      end
    end
  end
end
