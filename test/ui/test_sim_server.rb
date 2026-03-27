# frozen_string_literal: true

require 'minitest/autorun'
require 'rack/test'
require 'json'
require_relative '../../scripts/sim_server'

# Integration tests for the Simulation API server
class SimServerTest < Minitest::Test
  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

  def test_run_simulation_endpoint
    payload = build_valid_payload
    header 'Content-Type', 'application/json'
    post '/run', payload.to_json

    assert_predicate last_response, :ok?
    results = JSON.parse(last_response.body)
    verify_results(results)
  end

  def test_invalid_payload_handling
    post '/run', { invalid: 'data' }.to_json, { 'CONTENT_TYPE' => 'application/json' }

    assert_equal 500, last_response.status
  end

  private

  def build_valid_payload
    {
      num_simulations: 2,
      level: 1,
      teams: [
        { name: 'Heroes', members: [{ name: 'Hero', type: 'fighter' }] },
        { name: 'Monsters', members: [{ name: 'Goblin', type: 'goblin' }] }
      ]
    }
  end

  def verify_results(results)
    assert_kind_of Array, results
    assert_equal 2, results.length
    first_combat = results.first

    assert_includes first_combat['teams'], 'Hero'
    assert_includes first_combat['teams'], 'Goblin'
    refute_nil first_combat['winner']
    assert_kind_of Array, first_combat['rounds']
  end
end
