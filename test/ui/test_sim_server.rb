# frozen_string_literal: true

require 'minitest/autorun'
require 'rack/test'
require 'json'
require 'json-schema'
require_relative '../../scripts/sim_server'

# Integration tests for the Simulation API server including Schema and Math Validation
class SimServerTest < Minitest::Test
  include Rack::Test::Methods

  SCHEMA_PATH = File.expand_path('schemas/simulation_response.json', __dir__)

  def app
    Sinatra::Application
  end

  def test_root_route_serves_html_for_browser
    # Simulates a default browser request (no specific Accept or preferred HTML)
    get '/'

    assert_predicate last_response, :ok?
    assert_includes last_response.content_type, 'text/html'
    assert_includes last_response.body, '<!doctype html>'
  end

  def test_api_health_serves_json
    get '/api/health'

    assert_predicate last_response, :ok?
    assert_includes last_response.content_type, 'application/json'
    results = JSON.parse(last_response.body)

    assert_equal 'online', results['status']
  end

  def test_list_simulations
    get '/api/simulations'

    assert_predicate last_response, :ok?
    results = JSON.parse(last_response.body)

    assert_kind_of Array, results
    assert(results.any? { |s| s['id'] == 'champion-vs-bugbear-pack' })
  end

  def test_run_preset_simulation
    post '/api/simulations/run/champion-vs-bugbear-pack'

    assert_predicate last_response, :ok?
    batch = JSON.parse(last_response.body)

    assert_kind_of Array, batch['results']
    refute batch['is_batch']
  end

  def test_run_simulation_contract_and_math
    payload = build_valid_payload
    header 'Content-Type', 'application/json'
    post '/api/run', payload.to_json

    assert_predicate last_response, :ok?
    batch = JSON.parse(last_response.body)
    results = batch['results'][0]['data']

    JSON::Validator.validate!(SCHEMA_PATH, results)
    audit_math_consistency(results)
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

  def audit_math_consistency(results)
    results.each do |combat|
      combat['rounds'].each do |round|
        round['events'].each do |event|
          next unless event['type'] == 'attack'

          verify_attack_roll(event, round['number'])
          verify_damage_math(event, round['number'])
        end
      end
    end
  end

  def verify_attack_roll(event, round_num)
    meta = event['metadata']
    return unless meta['attack_roll']

    expected_roll = meta['picked_roll'] + meta['modifier']

    assert_equal expected_roll, meta['attack_roll'], "Attack roll mismatch in Round #{round_num}"
  end

  def verify_damage_math(event, round_num)
    return unless event['damage'].positive?

    meta = event['metadata']
    expected_damage = meta['damage_rolls'].sum + meta['damage_modifier']

    assert_equal expected_damage, event['damage'], "Damage calculation mismatch in Round #{round_num}"
  end
end
