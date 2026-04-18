# frozen_string_literal: true

require_relative '../lib/dnd5e/simulation/runner'
require_relative '../lib/dnd5e/simulation/scenario_builder'
require_relative '../lib/dnd5e/simulation/balance_evaluator'
require_relative '../lib/dnd5e/simulation/json_combat_result_handler'
require_relative '../lib/dnd5e/simulation/variable_expander'
require_relative 'sim_server'
require 'json'

module Dnd5e
  module Tools
    # Validator for the grid migration to ensure no statistical drift.
    class GridValidator
      ITERATIONS = 1000
      PRESETS_DIR = 'data/simulations/presets'

      def run
        puts 'Starting Phase 2: Statistical Validation of Grid Migration...'
        puts "Running #{ITERATIONS} iterations per preset...\n\n"

        presets = Dir.glob("#{PRESETS_DIR}/*.json")
        results = presets.flat_map { |p| validate_preset(p) }

        final_report(results)
      end

      private

      def validate_preset(path)
        preset_raw = JSON.parse(File.read(path))
        expanded = expand_presets(preset_raw)
        expanded.map { |p| run_validation(p) }
      end

      def expand_presets(raw)
        if raw['variables'] && !raw['variables'].empty?
          Simulation::VariableExpander.new.expand(raw)
        else
          [raw]
        end
      end

      def run_validation(preset)
        print "  Verifying #{preset['name']}... "
        sim_results = execute_simulations(preset)
        evaluation = Simulation::BalanceEvaluator.new.evaluate(sim_results, preset['expectations'] || [])

        report_evaluation(evaluation)
        { name: preset['name'], failed: (evaluation[:status] == :fail), evaluation: evaluation }
      end

      def execute_simulations(preset)
        handler = Simulation::JSONCombatResultHandler.new
        scenario = build_scenario(preset)
        runner = Simulation::Runner.new(scenario: scenario, result_handler: handler, logger: Logger.new(nil))
        runner.run
        JSON.parse(handler.to_json)
      end

      def report_evaluation(evaluation)
        if evaluation[:status] == :fail
          puts "\e[31m[FAIL]\e[0m"
          print_evaluation_details(evaluation[:details])
        else
          puts "\e[32m[PASS]\e[0m"
        end
      end

      def print_evaluation_details(details)
        details.each do |detail|
          next if detail[:status] == :pass

          puts "    - #{detail[:metric]} for #{detail[:combatant]}: " \
               "Expected #{detail[:min]}-#{detail[:max]}, Got #{detail[:actual].round(2)}"
        end
      end

      def build_scenario(cfg)
        builder = Simulation::ScenarioBuilder.new(num_simulations: ITERATIONS)
        cfg['teams'].each do |t_cfg|
          members = build_team_members(t_cfg, cfg['level'])
          builder.with_team(Core::Team.new(name: t_cfg['name'], members: members))
        end
        builder.build
      end

      def build_team_members(cfg, level)
        if cfg['members']
          cfg['members'].map { |m| build_unit(m, level) }
        elsif cfg['template'] && cfg['count']
          Array.new(cfg['count'].to_i) { build_unit(cfg['template'], level) }
        else
          []
        end
      end

      def build_unit(m_cfg, level)
        m_cfg['type'] == 'fighter' ? build_fighter_from_cfg(m_cfg, level) : build_monster_from_cfg(m_cfg)
      end

      def build_fighter_from_cfg(cfg, level)
        builder = Builders::CharacterBuilder.new(name: cfg['name'])
        builder.as_fighter(level: level, abilities: (cfg['abilities'] || {}).transform_keys(&:to_sym))
        builder.with_subclass(cfg['subclass'], level: level) if cfg['subclass']
        builder.build
      end

      def build_monster_from_cfg(cfg)
        builder = Builders::MonsterBuilder.new(name: cfg['name'])
        case cfg['type']
        when 'goblin' then builder.as_goblin
        when 'bugbear' then builder.as_bugbear
        when 'ogre' then builder.as_ogre
        end
        builder.build
      end

      def final_report(results)
        total = results.size
        failed = results.count { |r| r[:failed] }
        puts "\nValidation Summary:"
        puts "  Presets Checked: #{total}, Passed: #{total - failed}, Failed: #{failed}"

        if failed.positive?
          puts "\n\e[31mCRITICAL: Grid migration caused statistical drift outside allowed bounds!\e[0m"
          exit 1
        else
          puts "\n\e[32mSUCCESS: All results within expected statistical variance.\e[0m"
        end
      end
    end
  end
end

Dnd5e::Tools::GridValidator.new.run if __FILE__ == $PROGRAM_NAME
