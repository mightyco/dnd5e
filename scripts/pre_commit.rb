#!/usr/bin/env ruby
# frozen_string_literal: true

require 'open3'

def run_check(name, command)
  puts "Running #{name}..."
  stdout, stderr, status = Open3.capture3(command)
  
  if status.success?
    puts "#{name} passed."
    true
  else
    puts "#{name} failed!"
    puts stdout
    puts stderr
    false
  end
end

puts "Running pre-commit checks..."

lint_passed = run_check("RuboCop", "bundle exec rubocop")
tests_passed = run_check("Tests", "bundle exec rake test")

if lint_passed && tests_passed
  puts "All checks passed!"
  exit 0
else
  puts "Checks failed. Commit aborted."
  exit 1
end
