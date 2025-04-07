require_relative "result"
require_relative "combat_result_handler"

require 'logger'

module Dnd5e
  module Simulation
    class SilentCombatResultHandler < CombatResultHandler
      attr_reader :results, :logger

      def initialize(logger: Logger.new(nil))
        super()
        @results = []
        @logger = logger
      end

      def handle_result(combat, winner, initiative_winner)
        result = Result.new(winner: winner, initiative_winner: initiative_winner)
        @results << result
      end
    end
  end
end
