# frozen_string_literal: true

require 'rake'
require_relative '../dnd5e/simulation/variable_expander'
require_relative '../dnd5e/simulation/balance_evaluator'
require_relative '../../scripts/sim_server'

# Helper methods for balance regression testing.
module BalanceHelpers
  def self.run_balance_check(preset, evaluator)
    print "  Verifying #{preset['name']}... "
    handler = Dnd5e::Simulation::JSONCombatResultHandler.new
    builder = build_scenario_from_payload(preset)
    Dnd5e::Simulation::Runner.new(scenario: builder.build, result_handler: handler, logger: Logger.new(nil)).run
    results = JSON.parse(handler.to_json)
    outcome = evaluator.evaluate(results, preset['expectations'])
    puts outcome[:status] == :pass ? "\e[32mPASS\e[0m" : "\e[31mFAIL\e[0m"
    outcome
  end

  def self.report_failures(failures)
    puts "\n\e[31mBalance Regressions Detected:\e[0m"
    failures.each do |f|
      puts "  #{f[:name]}:"
      f[:details].each do |d|
        next if d[:status] == :pass

        puts "    - #{d[:metric]} for #{d[:combatant]}: Expected #{d[:min]}-#{d[:max]}, Got #{d[:actual].round(2)}"
      end
    end
    exit 1
  end
end

namespace :test do
  desc 'Run simulation presets and verify balance expectations'
  task balance: :environment do
    puts 'Running Balance Regression Tests...'
    presets_dir = File.expand_path('../../data/simulations/presets', __dir__)
    evaluator = Dnd5e::Simulation::BalanceEvaluator.new
    failures = []
    Dir.glob("#{presets_dir}/*.json").each do |path|
      preset = JSON.parse(File.read(path))
      next unless preset['expectations']

      outcome = BalanceHelpers.run_balance_check(preset, evaluator)
      failures << { name: preset['name'], details: outcome[:details] } if outcome[:status] == :fail
    end
    puts "\n\e[32mAll balance expectations met!\e[0m" if failures.empty?
    BalanceHelpers.report_failures(failures) unless failures.empty?
  end
end

task :environment unless Rake::Task.task_defined?(:environment)
