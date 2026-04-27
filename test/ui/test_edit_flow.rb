# frozen_string_literal: true

require 'minitest/autorun'
require 'rack/test'
require 'json'
require_relative '../../scripts/sim_server'

class TestEditFlow < Minitest::Test
  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

  def test_get_simulation_detail
    # Verify the API endpoint works
    get '/api/simulations/champion-vs-bugbear-pack'

    assert_predicate last_response, :ok?, "Expected OK response but got #{last_response.status}"
    data = JSON.parse(last_response.body)

    assert_equal 'champion-vs-bugbear-pack', data['id']
    assert_includes data.keys, 'teams'
  end

  def test_list_simulations_includes_metadata
    get '/api/simulations'

    assert_predicate last_response, :ok?
    sims = JSON.parse(last_response.body)

    fighter = sims.find { |s| s['id'] == 'champion-vs-bugbear-pack' }

    assert fighter, 'Champion vs Bugbear Pack preset not found in list'
    # Metadata should be present for the library view
    assert_includes fighter.keys, 'name'
    assert_includes fighter.keys, 'description'
  end
end
