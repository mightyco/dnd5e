# frozen_string_literal: true

require 'sinatra'
require 'json'
require 'fileutils'
require 'logger'
require_relative '../lib/dnd5e/builders/character_builder'
require_relative '../lib/dnd5e/builders/monster_builder'
require_relative '../lib/dnd5e/core/feat_registry'
require_relative '../lib/dnd5e/core/weapon_registry'
require_relative '../lib/dnd5e/core/subclass_registry'
require_relative '../lib/dnd5e/core/schema_registry'
require_relative '../lib/dnd5e/simulation/runner'
require_relative '../lib/dnd5e/simulation/json_combat_result_handler'
require_relative '../lib/dnd5e/simulation/variable_expander'
require_relative '../lib/dnd5e/simulation/scenario_builder'

# Configuration
UI_DIST_DIR = File.expand_path('../ui/dist', __dir__)
PRESETS_DIR = File.expand_path('../data/simulations/presets', __dir__)
CUSTOM_DIR = File.expand_path('../data/simulations/custom', __dir__)

set :public_folder, UI_DIST_DIR
set :port, 4567
set :bind, '0.0.0.0'

configure :test do
  set :protection, false
end

# Logging
logger = Logger.new('log/api.log')

# --- STATIC ASSETS ---

get '/' do
  send_file File.join(UI_DIST_DIR, 'index.html')
end

# Fallback for React Router / SPA
get %r{/(?!api|assets|favicon).*} do
  send_file File.join(UI_DIST_DIR, 'index.html')
end

get '/docs' do
  redirect '/docs/index.html'
end

get '/docs/*' do |path|
  docs_dir = File.expand_path('../docs/build', __dir__)
  file_path = File.join(docs_dir, path)
  file_path = File.join(file_path, 'index.html') if File.directory?(file_path)
  File.exist?(file_path) ? send_file(file_path) : halt(404, 'Docs Missing. Run rake unify:build')
end

# --- API ROUTES (Prefix Enforcement) ---

get '/api/health' do
  content_type :json
  { status: 'online', message: 'D&D 2024 Simulation API',
    ui_built: File.exist?(File.join(UI_DIST_DIR, 'index.html')) }.to_json
end

get '/api/metadata' do
  content_type :json
  build_metadata_payload.to_json
end

def build_metadata_payload
  cls, scs = discover_classes_and_subclasses
  assemble_metadata(cls, scs)
end

# rubocop:disable Metrics/MethodLength
def assemble_metadata(cls, scs)
  {
    classes: cls, subclasses: scs,
    monsters: %w[goblin bugbear ogre],
    types: { classes: cls, monsters: %w[goblin bugbear ogre] },
    feats: Dnd5e::Core::FeatRegistry.all_keys,
    fighting_styles: %w[archery defense dueling great_weapon_fighting protection two_weapon_fighting],
    maneuvers: %w[menacing_attack trip_attack pushing_attack precision_attack],
    weapons: Dnd5e::Core::WeaponRegistry.all_keys,
    armor: Dnd5e::Core::ArmorRegistry.all_keys.reject { |k| k == 'shield' },
    shields: ['shield'], ui_schema: build_ui_schema
  }
end
# rubocop:enable Metrics/MethodLength

def discover_classes_and_subclasses
  all_classes = %w[fighter wizard rogue barbarian paladin monk ranger cleric bard druid sorcerer warlock]
  subclasses = Dnd5e::Core::SubclassRegistry.all_by_class
  all_classes.each { |cls| subclasses[cls.to_sym] ||= [] }
  [all_classes, subclasses]
end

def build_ui_schema
  Dnd5e::Core::SchemaRegistry.load_ui_schema
end

['/simulations', '/api/simulations'].each do |path|
  get path do
    content_type :json
    (list_simulations(PRESETS_DIR, 'preset') + list_simulations(CUSTOM_DIR, 'custom')).to_json
  end
end

['/simulations/:id', '/api/simulations/:id'].each do |path|
  get path do
    content_type :json
    sim = find_simulation(params[:id])
    halt 404, { error: 'Simulation not found' }.to_json unless sim
    sim.to_json
  end
end

['/simulations/run/:id', '/api/simulations/run/:id'].each do |path|
  post path do
    content_type :json
    sim = find_simulation(params[:id])
    halt 404, { error: 'Simulation not found' }.to_json unless sim
    run_sim_batch(sim)
  rescue StandardError => e
    halt 500, { error: e.message }.to_json
  end
end

['/run', '/api/run'].each do |path|
  post path do
    content_type :json
    run_sim_batch(JSON.parse(request.body.read))
  rescue StandardError => e
    logger.error "Simulation error: #{e.message}\n#{e.backtrace.join("\n")}"
    halt 500, { error: e.message }.to_json
  end
end

['/simulations/save', '/api/simulations/save'].each do |path|
  post path do
    content_type :json
    save_custom_sim(JSON.parse(request.body.read))
  rescue StandardError => e
    halt 500, { error: e.message }.to_json
  end
end

# --- HELPERS ---

def list_simulations(dir, type)
  return [] unless Dir.exist?(dir)

  Dir.glob("#{dir}/*.json").map do |path|
    map_simulation_file(path, type)
  end
end

def map_simulation_file(path, type)
  data = JSON.parse(File.read(path))
  {
    id: File.basename(path, '.json'),
    name: data['name'],
    description: data['description'],
    type: type,
    level: data['level'],
    num_simulations: data['num_simulations'],
    is_variable: !data['variables'].nil?
  }
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
    # Enable snapshots for UI visualization
    handler = Dnd5e::Simulation::JSONCombatResultHandler.new(capture_snapshots: true)
    builder = build_scenario_from_payload(payload)
    Dnd5e::Simulation::Runner.new(scenario: builder.build, result_handler: handler, logger: Logger.new(nil)).run
    { parameters: payload['sweep_parameters'], data: JSON.parse(handler.to_json) }
  end

  { is_batch: scenarios.length > 1, results: results }.to_json
end

def build_scenario_from_payload(payload)
  builder = Dnd5e::Simulation::ScenarioBuilder.new(
    num_simulations: payload['num_simulations'] || 100,
    max_rounds: payload['max_rounds'] || 100,
    distance: payload['distance'] || 30
  )
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
  classes = %w[fighter wizard rogue barbarian paladin monk ranger cleric bard druid sorcerer warlock]
  if classes.include?(cfg['type'])
    build_character(Dnd5e::Builders::CharacterBuilder.new(name: cfg['name']), cfg, level)
  else
    build_monster(cfg)
  end
end

def build_monster(cfg)
  builder = Dnd5e::Builders::MonsterBuilder.new(name: cfg['name'])
  case cfg['type']
  when 'goblin' then builder.as_goblin
  when 'bugbear' then builder.as_bugbear
  when 'ogre' then builder.as_ogre
  end

  builder.with_ac(cfg['ac'].to_i) if cfg['ac']
  builder.with_hp(cfg['hp'].to_i) if cfg['hp']

  builder.build
end

def build_character(builder, cfg, level)
  abilities = (cfg['abilities'] || {}).transform_keys(&:to_sym)
  builder.send("as_#{cfg['type']}", level: level, abilities: abilities)
  apply_character_options(builder, cfg, level)
  apply_custom_equipment(builder, cfg)
  apply_feats(builder, cfg['feats'])
  builder.build
end

def apply_character_options(builder, cfg, level)
  subclass = cfg['subclass']
  subclass = nil if subclass == ''
  builder.with_subclass(subclass, level: level) if subclass
  builder.with_fighting_style(cfg['fightingStyle']) if cfg['fightingStyle']

  return unless cfg['maneuvers'].is_a?(Array)

  builder.with_strategy(Dnd5e::Core::Strategies::BattleMasterStrategy.new) # Ensure BM strategy
  # If we add specific maneuver support to strategy, we would pass them here
end

def apply_custom_equipment(builder, cfg)
  # Custom Equipment (overrides class defaults if provided)
  builder.with_weapon(cfg['weapon']) if cfg['weapon']
  builder.with_armor(cfg['armor']) if cfg['armor']
  builder.with_shield if cfg['shield']
end

def apply_feats(builder, feats)
  return unless feats.is_a?(Array)

  feats.each do |feat_key|
    builder.with_feature(Dnd5e::Core::FeatRegistry.create(feat_key))
  end
end
