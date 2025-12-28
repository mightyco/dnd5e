#!/usr/bin/env ruby
# frozen_string_literal: true

require 'open3'

def run_check?(name, command)
  puts "Running #{name}..."
  stdout, stderr, status = Open3.capture3(command)

  return true if status.success?

  log_failure(name, stdout, stderr)
  false
end

def log_failure(name, stdout, stderr)
  puts "#{name} failed!"
  puts stdout
  puts stderr
end

puts 'Running pre-commit checks...'

lint_passed = run_check?('RuboCop', 'bundle exec rubocop')
tests_passed = run_check?('Tests', 'bundle exec rake test')

if lint_passed && tests_passed
  puts 'All checks passed!'
  exit 0
else
  puts 'Checks failed. Commit aborted.'
  exit 1
end
