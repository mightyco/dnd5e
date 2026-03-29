# frozen_string_literal: true

require 'sinatra'
require 'sinatra/cross_origin'
require 'json'
require_relative '../lib/dnd5e/simulation/runner'
require_relative '../lib/dnd5e/simulation/scenario_builder'
require_relative '../lib/dnd5e/simulation/json_combat_result_handler'
require_relative '../lib/dnd5e/builders/character_builder'
require_relative '../lib/dnd5e/builders/monster_builder'

set :bind, '0.0.0.0'
set :port, 4567

configure do
  enable :cross_origin
  disable :protection
  set :host_authorization, { permitted_hosts: [] }
end

before do
  response.headers['Access-Control-Allow-Origin'] = '*'
end

options '*' do
  response.headers['Allow'] = 'GET, PUT, POST, DELETE, OPTIONS'
  response.headers['Access-Control-Allow-Headers'] = 'Authorization, Content-Type, Accept, X-User-Email, X-Auth-Token'
  response.headers['Access-Control-Allow-Origin'] = '*'
  200
end

get '/' do
  content_type :json
  { status: 'online', message: 'D&D 2024 Simulation API' }.to_json
end

# Helper to build a member from configuration
def build_member(member_cfg, level)
  case member_cfg['type']
  when 'fighter'
    Dnd5e::Builders::CharacterBuilder.new(name: member_cfg['name']).as_fighter(level: level).build
  when 'goblin'
    Dnd5e::Builders::MonsterBuilder.new(name: member_cfg['name']).as_goblin.build
  when 'bugbear'
    Dnd5e::Builders::MonsterBuilder.new(name: member_cfg['name']).as_bugbear.build
  end
end

# Main simulation run endpoint
post '/run' do
  content_type :json
  payload = JSON.parse(request.body.read)
  num_sims = payload['num_simulations'] || 100
  level = payload['level'] || 1
  builder = Dnd5e::Simulation::ScenarioBuilder.new(num_simulations: num_sims)
  payload['teams'].each do |team_cfg|
    members = team_cfg['members'].map { |m| build_member(m, level) }
    builder.with_team(Dnd5e::Core::Team.new(name: team_cfg['name'], members: members))
  end
  handler = Dnd5e::Simulation::JSONCombatResultHandler.new
  Dnd5e::Simulation::Runner.new(scenario: builder.build, result_handler: handler, logger: Logger.new(nil)).run
  handler.to_json
rescue StandardError => e
  halt 500, { error: e.message }.to_json
end

puts 'Simulation API Server running on http://localhost:4567'
