# frozen_string_literal: true

require 'rake'
require_relative '../dnd5e/tools/balance_checker'

# Helper methods for balance reporting to keep Rake tasks lean.
module BalanceHelpers
  def self.report_results(results)
    failures = results.select { |r| r[:status] == :fail }

    if failures.empty?
      report_success(results.size)
    else
      report_failures(failures)
      exit 1
    end
  end

  def self.report_success(count)
    puts "\n\e[32mAll balance expectations met! (#{count} scenarios checked)\e[0m"
  end

  def self.report_failures(failures)
    puts "\n\e[31mBalance Regressions Detected:\e[0m"
    failures.each do |f|
      puts "  #{f[:name]}:"
      f[:details].each do |d|
        next if d[:status] == :pass

        puts "    - #{d[:metric]}: Expected #{d[:min]}-#{d[:max]}, Got #{d[:actual].round(2)}"
      end
    end
  end
end

namespace :test do
  namespace :balance do
    desc 'Run high-precision balance audit (1000 iterations, full variable sweep)'
    task :full do
      puts 'Running High-Precision Balance Audit...'
      checker = Dnd5e::Tools::BalanceChecker.new(iterations: 1000)
      results = checker.run_all
      BalanceHelpers.report_results(results)
    end
  end

  desc 'Run fast balance smoke test (100 iterations)'
  task :balance do
    puts 'Running Balance Smoke Test...'
    checker = Dnd5e::Tools::BalanceChecker.new(iterations: 100)
    results = checker.run_all
    BalanceHelpers.report_results(results)
  end
end
