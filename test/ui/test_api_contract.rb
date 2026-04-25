# frozen_string_literal: true

require_relative '../test_helper'
require 'rack/test'
require 'json'
require_relative '../../scripts/sim_server'

module Dnd5e
  # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
  class TestApiContract < Minitest::Test
    include Rack::Test::Methods

    def app
      Sinatra::Application
    end

    def test_run_response_contract
      payload = {
        'num_simulations' => 1,
        'level' => 5,
        'teams' => [
          { 'name' => 'Heroes', 'members' => [{ 'name' => 'Hero', 'type' => 'fighter' }] },
          { 'name' => 'Monsters', 'members' => [{ 'name' => 'Goblin', 'type' => 'goblin' }] }
        ]
      }

      post '/api/run', payload.to_json, { 'CONTENT_TYPE' => 'application/json' }

      assert_predicate last_response, :ok?

      data = JSON.parse(last_response.body)

      assert_kind_of Hash, data
      assert_includes data.keys, 'results'

      result_data = data['results'].first['data']

      assert_kind_of Array, result_data

      combat = result_data.first

      assert_includes combat.keys, 'teams'
      assert_includes combat.keys, 'rounds'
      assert_includes combat.keys, 'winner'

      # Verify Math Transparency metadata
      round = combat['rounds'].first

      assert_includes round.keys, 'events'

      attack_event = round['events'].find { |e| %w[attack save].include?(e['type']) }
      return unless attack_event

      metadata = attack_event['metadata']
      assert_includes metadata.keys, 'attack_roll' if attack_event['type'] == 'attack'

      assert_includes metadata.keys, 'damage_rolls'
    end

    def test_empty_data_handling
      # This is more of a UI requirement, but we can verify the API returns
      # valid but empty-ish structures if possible.
    end
  end
end
# rubocop:enable Metrics/AbcSize, Metrics/MethodLength
