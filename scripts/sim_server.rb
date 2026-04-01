# frozen_string_literal: true

require 'sinatra'
require 'sinatra/cross_origin'
require 'json'
require 'fileutils'
require_relative '../lib/dnd5e/simulation/runner'
require_relative '../lib/dnd5e/simulation/scenario_builder'
require_relative '../lib/dnd5e/simulation/json_combat_result_handler'
require_relative '../lib/dnd5e/simulation/variable_expander'
require_relative '../lib/dnd5e/builders/character_builder'
require_relative '../lib/dnd5e/builders/monster_builder'
require_relative '../lib/dnd5e/core/features/improved_critical'
require_relative '../lib/dnd5e/core/features/battle_master'

set :bind, '0.0.0.0'
set :port, 4567

PRESETS_DIR = File.expand_path('../data/simulations/presets', __dir__)
CUSTOM_DIR = File.expand_path('../data/simulations/custom', __dir__)
UI_DIST_DIR = File.expand_path('../ui/dist', __dir__)
DOCS_BUILD_DIR = File.expand_path('../docs/portal/build', __dir__)

configure do
  enable :cross_origin
  disable :protection
  set :host_authorization, { permitted_hosts: [] } if development?
  set :public_folder, UI_DIST_DIR
end

before do
  response.headers['Access-Control-Allow-Origin'] = '*'
end

# --- UI ROUTES (Strict Isolation) ---

# The root route is EXCLUSIVELY for the Human UI.
# It will never return JSON to prevent browser content negotiation bugs.
get '/' do
  index = File.join(UI_DIST_DIR, 'index.html')
  halt 404, 'UI Build Missing. Run rake unify:build' unless File.exist?(index)
  send_file index
end

get '/docs/?*' do
  path = params[:splat].first
  path = 'index.html' if path.nil? || path.empty?
  file_path = File.join(DOCS_BUILD_DIR, path)
  file_path = File.join(file_path, 'index.html') if File.directory?(file_path)
  File.exist?(file_path) ? send_file(file_path) : halt(404, 'Docs Missing. Run rake unify:build')
end

# --- API ROUTES (Prefix Enforcement) ---

get '/api/health' do
  content_type :json
  { status: 'online', message: 'D&D 2024 Simulation API',
    ui_built: File.exist?(File.join(UI_DIST_DIR, 'index.html')) }.to_json
end

['/simulations', '/api/simulations'].each do |path|
  get path do
    content_type :json
    (list_simulations(PRESETS_DIR, 'preset') + list_simulations(CUSTOM_DIR, 'custom')).to_json
  end
end

['/simulations/run/:id', '/api/simulations/run/:id'].each do |path|
  post path do
    content_type :json
    sim = find_simulation(params[:id])
    halt 404, { error: 'Simulation not found' }.to_json unless sim
    run_sim_batch(sim)
  end
end

['/run', '/api/run'].each do |path|
  post path do
    content_type :json
    run_sim_batch(JSON.parse(request.body.read))
  rescue StandardError => e
    halt 500, { error: e.message }.to_json
  end
end

['/simulations/save', '/api/simulations/save'].each do |path|
  post path do
    content_type :json
    payload = JSON.parse(request.body.read)
    halt 400, { error: 'ID is required' }.to_json unless payload['id']
    save_custom_sim(payload)
  end
end

# --- HELPERS ---

def list_simulations(dir, type)
  return [] unless Dir.exist?(dir)

  Dir.glob("#{dir}/*.json").map { |p| format_sim_metadata(p, JSON.parse(File.read(p)), type) }
end

def format_sim_metadata(path, data, type)
  { id: File.basename(path, '.json'), name: data['name'], description: data['description'],
    type: type, level: data['level'], num_simulations: data['num_simulations'],
    is_variable: !data['variables']&.empty? }
end

def find_simulation(id)
  [PRESETS_DIR, CUSTOM_DIR].each do |dir|
    path = File.join(dir, "#{id}.json")
    return JSON.parse(File.read(path)) if File.exist?(path)
  end
  nil
end

def save_custom_sim(payload)
  FileUtils.mkdir_p(CUSTOM_DIR)
  path = File.join(CUSTOM_DIR, "#{payload['id']}.json")
  File.write(path, JSON.pretty_generate(payload))
  { status: 'success', path: path }.to_json
end

def run_sim_batch(preset)
  expander = Dnd5e::Simulation::VariableExpander.new
  scenarios = expander.expand(preset)

  results = scenarios.map do |payload|
    handler = Dnd5e::Simulation::JSONCombatResultHandler.new
    builder = build_scenario_from_payload(payload)
    Dnd5e::Simulation::Runner.new(scenario: builder.build, result_handler: handler, logger: Logger.new(nil)).run
    { parameters: payload['sweep_parameters'], data: JSON.parse(handler.to_json) }
  end

  { is_batch: scenarios.length > 1, results: results }.to_json
end

def build_scenario_from_payload(payload)
  builder = Dnd5e::Simulation::ScenarioBuilder.new(num_simulations: payload['num_simulations'] || 100)
  payload['teams'].each do |team_cfg|
    members = build_team_members(team_cfg, payload['level'] || 1)
    builder.with_team(Dnd5e::Core::Team.new(name: team_cfg['name'], members: members))
  end
  builder
end

def build_team_members(team_cfg, level)
  count = (team_cfg['count'] || 1).to_i
  if team_cfg['template']
    Array.new(count) { build_member(team_cfg['template'], level) }
  else
    team_cfg['members'].map { |m| build_member(m, level) }
  end
end

def build_member(cfg, level)
  case cfg['type']
  when 'fighter' then build_fighter(Dnd5e::Builders::CharacterBuilder.new(name: cfg['name']), cfg, level)
  when 'wizard' then Dnd5e::Builders::CharacterBuilder.new(name: cfg['name']).as_wizard(level: level).build
  else build_monster(cfg)
  end
end

def build_monster(cfg)
  builder = Dnd5e::Builders::MonsterBuilder.new(name: cfg['name'])
  case cfg['type']
  when 'goblin' then builder.as_goblin.build
  when 'bugbear' then builder.as_bugbear.build
  when 'ogre' then builder.as_ogre.build
  end
end

def build_fighter(builder, cfg, level)
  builder.as_fighter(level: level, abilities: (cfg['abilities'] || {}).transform_keys(&:to_sym))
  add_subclass_features(builder, cfg['subclass'], level) if cfg['subclass']
  builder.build
end

def add_subclass_features(builder, subclass, level)
  case subclass
  when 'champion' then builder.with_feature(Dnd5e::Core::Features::ImprovedCritical.new)
  when 'battlemaster' then builder.with_feature(Dnd5e::Core::Features::BattleMaster.new(level: level))
  end
end
