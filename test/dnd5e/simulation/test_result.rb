# frozen_string_literal: true

require_relative '../../test_helper'
require_relative '../../../lib/dnd5e/simulation/result'
require_relative '../../../lib/dnd5e/core/team'

module Dnd5e
  module Simulation
    class TestResult < Minitest::Test
      def test_result_initialization
        # Use real Team objects instead of mocks
        winner = Core::Team.new(name: 'Winner Team', members: [])
        initiative_winner = Core::Team.new(name: 'Initiative Winner Team', members: [])
        result = Result.new(winner: winner, initiative_winner: initiative_winner)

        assert_equal winner, result.winner
        assert_equal initiative_winner, result.initiative_winner
      end
    end
  end
end
