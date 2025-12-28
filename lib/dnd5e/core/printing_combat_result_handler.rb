# frozen_string_literal: true

require_relative 'combat_result_handler'
require 'logger'

module Dnd5e
  module Core
    # Handles reporting combat results to a logger in a human-readable format.
    class PrintingCombatResultHandler < CombatResultHandler
      attr_reader :logger

      def initialize(logger: Logger.new($stdout))
        super()
        @logger = logger
        logger.formatter = proc do |_severity, _datetime, _progname, msg|
          "#{msg}\n"
        end
      end

      def handle_result(_combat, winner, initiative_winner)
        logger.info 'Combat Over'
        logger.info "Winner: #{winner.name}"
        logger.info "Initiative Winner: #{initiative_winner.name}"
      end
    end
  end
end
