require_relative "result"

require 'logger'

module Dnd5e
  module Simulation
    class SilentCombatResultHandler
      def initialize(logger: Logger.new(nil))
        @results = []
        @logger = logger
      end

      def handle_result(combat, winner, initiative_winner, logger: @logger)
        result = Result.new(winner: winner, initiative_winner: initiative_winner)
        @results << result
      end

      def results
        @results
      end
    end
  end
end
