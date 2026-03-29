# frozen_string_literal: true

require 'sinatra'
require 'sinatra/cross_origin'
require 'json'
require 'fileutils'
require_relative '../lib/dnd5e/simulation/runner'
require_relative '../lib/dnd5e/simulation/scenario_builder'
require_relative '../lib/dnd5e/simulation/json_combat_result_handler'
require_relative '../lib/dnd5e/builders/character_builder'
require_relative '../lib/dnd5e/builders/monster_builder'

set :bind, '0.0.0.0'
set :port, 4567

PRESETS_DIR = File.expand_path('../data/simulations/presets', __dir__)
CUSTOM_DIR = File.expand_path('../data/simulations/custom', __dir__)

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

# List all available simulations
get '/simulations' do
  content_type :json
  presets = list_simulations(PRESETS_DIR, 'preset')
  custom = list_simulations(CUSTOM_DIR, 'custom')
  (presets + custom).to_json
end

# Run a specific simulation by ID
post '/simulations/run/:id' do
  content_type :json
  sim = find_simulation(params[:id])
  halt 404, { error: 'Simulation not found' }.to_json unless sim

  run_sim_payload(sim)
end

# Main simulation run endpoint (direct payload)
post '/run' do
  content_type :json
  payload = JSON.parse(request.body.read)
  run_sim_payload(payload)
rescue StandardError => e
  halt 500, { error: e.message }.to_json
end

# Save a custom trial
post '/simulations/save' do
  content_type :json
  payload = JSON.parse(request.body.read)
  halt 400, { error: 'ID is required' }.to_json unless payload['id']

  FileUtils.mkdir_p(CUSTOM_DIR)
  path = File.join(CUSTOM_DIR, "#{payload['id']}.json")
  File.write(path, JSON.pretty_generate(payload))
  { status: 'success', path: path }.to_json
end

# --- HELPERS ---

def list_simulations(dir, type)
  return [] unless Dir.exist?(dir)

  Dir.glob("#{dir}/*.json").map do |path|
    data = JSON.parse(File.read(path))
    format_sim_metadata(path, data, type)
  end
end

def format_sim_metadata(path, data, type)
  {
    id: File.basename(path, '.json'),
    name: data['name'],
    description: data['description'],
    type: type,
    level: data['level'],
    num_simulations: data['num_simulations']
  }
end

def find_simulation(id)
  [PRESETS_DIR, CUSTOM_DIR].each do |dir|
    path = File.join(dir, "#{id}.json")
    return JSON.parse(File.read(path)) if File.exist?(path)
  end
  nil
end

def run_sim_payload(payload)
  builder = build_scenario_from_payload(payload)
  handler = Dnd5e::Simulation::JSONCombatResultHandler.new
  Dnd5e::Simulation::Runner.new(scenario: builder.build, result_handler: handler, logger: Logger.new(nil)).run
  handler.to_json
end

def build_scenario_from_payload(payload)
  num_sims = payload['num_simulations'] || 100
  builder = Dnd5e::Simulation::ScenarioBuilder.new(num_simulations: num_sims)
  add_teams_to_builder(builder, payload['teams'], payload['level'] || 1)
  builder
end

def add_teams_to_builder(builder, teams, level)
  teams.each do |team_cfg|
    members = team_cfg['members'].map { |m| build_member(m, level) }
    builder.with_team(Dnd5e::Core::Team.new(name: team_cfg['name'], members: members))
  end
end

def build_member(member_cfg, level)
  builder = Dnd5e::Builders::CharacterBuilder.new(name: member_cfg['name'])
  case member_cfg['type']
  when 'fighter' then build_fighter(builder, member_cfg, level)
  when 'wizard' then builder.as_wizard(level: level).build
  when 'goblin' then Dnd5e::Builders::MonsterBuilder.new(name: member_cfg['name']).as_goblin.build
  when 'bugbear' then Dnd5e::Builders::MonsterBuilder.new(name: member_cfg['name']).as_bugbear.build
  end
end

def build_fighter(builder, member_cfg, level)
  abilities = member_cfg['abilities'] || {}
  symbolized_abilities = abilities.transform_keys(&:to_sym)
  builder.as_fighter(level: level, abilities: symbolized_abilities)
  builder.with_subclass(member_cfg['subclass'], level: level) if member_cfg['subclass']
  builder.build
end

puts 'Simulation API Server running on http://localhost:4567'
