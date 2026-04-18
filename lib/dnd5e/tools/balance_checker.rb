# frozen_string_literal: true

require_relative '../simulation/runner'
require_relative '../simulation/scenario_builder'
require_relative '../simulation/balance_evaluator'
require_relative '../simulation/json_combat_result_handler'
require_relative '../simulation/variable_expander'
require_relative '../builders'
require 'json'

module Dnd5e
  module Tools
    # High-precision tool for auditing engine balance and mathematical integrity.
    class BalanceChecker
      attr_reader :iterations, :presets_dir

      def initialize(iterations: 1000, presets_dir: 'data/simulations/presets')
        @iterations = iterations
        @presets_dir = presets_dir
      end

      def run_all
        presets = Dir.glob("#{presets_dir}/*.json")
        presets.flat_map { |p| run_preset(p) }
      end

      def run_preset(path)
        preset_raw = JSON.parse(File.read(path))
        expanded = expand_presets(preset_raw)

        expanded.map { |preset| verify_config(preset) }
      end

      private

      def verify_config(preset)
        handler = Simulation::JSONCombatResultHandler.new
        scenario = build_scenario(preset)
        runner = Simulation::Runner.new(scenario: scenario, result_handler: handler, logger: Logger.new(nil))
        runner.run
        evaluate_results(preset, handler.to_json)
      end

      def evaluate_results(preset, json_results)
        sim_results = JSON.parse(json_results)
        evaluation = Simulation::BalanceEvaluator.new.evaluate(sim_results, preset['expectations'] || [])
        { name: preset['name'], status: evaluation[:status], details: evaluation[:details] }
      end

      def expand_presets(raw)
        if raw['variables'] && !raw['variables'].empty?
          Simulation::VariableExpander.new.expand(raw)
        else
          [raw]
        end
      end

      def build_scenario(cfg)
        builder = Simulation::ScenarioBuilder.new(num_simulations: iterations)
        cfg['teams'].each do |t_cfg|
          members = build_members(t_cfg, cfg['level'])
          builder.with_team(Core::Team.new(name: t_cfg['name'], members: members))
        end
        builder.build
      end

      def build_members(cfg, level)
        if cfg['members']
          cfg['members'].map { |m| build_unit(m, level) }
        elsif cfg['template'] && cfg['count']
          Array.new(cfg['count'].to_i) { build_unit(cfg['template'], level) }
        else
          []
        end
      end

      def build_unit(m_cfg, level)
        m_cfg['type'] == 'fighter' ? build_fighter(m_cfg, level) : build_monster(m_cfg)
      end

      def build_fighter(cfg, level)
        builder = Builders::CharacterBuilder.new(name: cfg['name'])
        builder.as_fighter(level: level, abilities: (cfg['abilities'] || {}).transform_keys(&:to_sym))
        builder.with_subclass(cfg['subclass'], level: level) if cfg['subclass']
        builder.build
      end

      def build_monster(cfg)
        builder = Builders::MonsterBuilder.new(name: cfg['name'])
        case cfg['type']
        when 'goblin' then builder.as_goblin
        when 'bugbear' then builder.as_bugbear
        when 'ogre' then builder.as_ogre
        end
        builder.build
      end
    end
  end
end
