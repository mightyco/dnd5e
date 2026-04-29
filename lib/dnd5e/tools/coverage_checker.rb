# frozen_string_literal: true

require 'json'

module Dnd5e
  module Tools
    # Logic for checking code coverage against thresholds.
    class CoverageChecker
      def initialize(config)
        @config = config
      end

      def check
        validate_files!
        current = read_current_coverage
        baseline = read_baseline

        print_report(current, baseline)

        errors = find_errors(current, baseline)
        handle_results(errors, current)
      end

      private

      def validate_files!
        return if File.exist?(@config::LAST_RUN_FILE)

        puts 'Coverage data missing! Run tests first.'
        exit 1
      end

      def read_current_coverage
        JSON.parse(File.read(@config::LAST_RUN_FILE))['result']['line']
      end

      def read_baseline
        File.exist?(@config::BASELINE_FILE) ? File.read(@config::BASELINE_FILE).to_f : 0.0
      end

      def print_report(current, baseline)
        puts "\nCoverage Report:"
        puts "  Current:  #{current}%"
        puts "  Baseline: #{baseline}%"
        puts "  Floor:    #{@config::FLOOR}%"
      end

      def find_errors(current, baseline)
        errors = []
        errors << "Overall coverage (#{current}%) is below floor (#{@config::FLOOR}%)" if current < @config::FLOOR
        if baseline.positive? && current < (baseline - @config::REGRESSION_THRESHOLD)
          errors << "Coverage regressed more than #{@config::REGRESSION_THRESHOLD}%"
        end
        errors
      end

      def handle_results(errors, current)
        if errors.any?
          errors.each { |e| puts "  [FAILURE] #{e}" }
          puts "\nAction Required: Increase test coverage or run 'rake test:coverage:record'."
          exit 1
        else
          puts '  [SUCCESS] Coverage requirements met.'
          File.write(@config::BASELINE_FILE, current.to_s)
          puts "  [INFO] Auto-updated baseline to #{current}%"
        end
      end
    end
  end
end
