# frozen_string_literal: true

require 'minitest/autorun'
require 'rack/test'
require 'json'
require_relative '../../scripts/sim_server'

module Dnd5e
  # Contract tests for the Simulation API
  class TestApiContract < Minitest::Test
    include Rack::Test::Methods

    def app
      Sinatra::Application
    end

    def test_run_response_contract
      payload = build_contract_payload
      setup_contract_headers
      post '/api/run', payload.to_json

      assert_predicate last_response, :ok?
      verify_response_data(JSON.parse(last_response.body))
    end

    private

    def build_contract_payload
      {
        num_simulations: 1, level: 5,
        teams: [
          { 'name' => 'Heroes', 'members' => [{ 'name' => 'Hero', 'type' => 'fighter' }] },
          { 'name' => 'Monsters', 'members' => [{ 'name' => 'Goblin', 'type' => 'goblin' }] }
        ]
      }
    end

    def setup_contract_headers
      header 'Host', 'localhost'
      header 'Content-Type', 'application/json'
    end

    def verify_response_data(data)
      assert_includes data.keys, 'is_batch'
      assert_kind_of Array, data['results']

      result = data['results'].first

      assert_includes result.keys, 'parameters'
      assert_kind_of Array, result['data']

      battle = result['data'].first
      verify_battle_structure(battle)
    end

    def verify_battle_structure(battle)
      assert_includes battle.keys, 'winner'
      assert_includes battle.keys, 'rounds'
      assert_includes battle.keys, 'initial_positions'

      verify_battle_snapshots(battle)
    end

    def verify_battle_snapshots(battle)
      round = battle['rounds'].first
      event = round['events'].find { |e| e['type'] == 'turn_start' }

      assert event['snapshot'], 'Snapshots must be present'
      assert event['snapshot'].values.all? { |s| s.key?('team') }, 'Snapshots must include team'
    end
  end
end
