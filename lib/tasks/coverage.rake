# frozen_string_literal: true

require 'json'
require_relative '../../lib/dnd5e/tools/coverage_checker'

# Configuration for coverage checks.
module CoverageConfig
  BASELINE_FILE = '.coverage_baseline'
  LAST_RUN_FILE = 'coverage/.last_run.json'
  FLOOR = 90.0
  REGRESSION_THRESHOLD = 0.5
end

namespace :test do
  namespace :coverage do
    desc 'Check coverage against floor and baseline'
    task check: :test do
      Dnd5e::Tools::CoverageChecker.new(CoverageConfig).check
    end

    desc 'Record current coverage as the new baseline'
    task record: :test do
      current = JSON.parse(File.read(CoverageConfig::LAST_RUN_FILE))['result']['line']
      File.write(CoverageConfig::BASELINE_FILE, current.to_s)
      puts "Recorded new baseline: #{current}%"
    end
  end
end
