require 'rake/testtask'
require "minitest/test_task"

task :install do
  sh "bundle install"
end

task :test => "test:default"

Minitest::TestTask.create(:all) do |t|
  t.libs << "test"
  t.libs << "lib"
  t.warning = false
  t.test_globs = ["test/**/test_*.rb"]
end

namespace :test do
  desc "List available tests files and classes"
  task :list do
    test_files = Dir["test/**/test_*.rb"]
    test_classes = {}
    test_files.each do |file|
      content = File.read(file)
      content.scan(/class\s+([A-Za-z0-9:]+)\s*<\s*Minitest::Test/) do |match|
        if test_classes.key?(file)
          test_classes[file] << match[0]
        else
          test_classes[file] = [match[0]]
        end
      end
    end
    puts "Available Tests"
    test_classes.keys.sort.each { |f| puts "  - #{f} : #{test_classes[f].join(',')}" }
  end

  desc "List available tests in a file"
  task :tests, [:file] do |t, args|
    file = args[:file]
    unless file
      puts "Usage: rake test:list_tests[test/path/to/test_file.rb]"
      exit 1
    end
    unless File.exist?(file)
      puts "File not found: #{file}"
      exit 1
    end
    content = File.read(file)
    tests = []
    content.scan(/def\s+test_([a-z0-9_]+)/) do |match|
      tests << match[0]
    end
    puts "Available Tests in #{file}:"
    tests.sort.each { |test| puts "  - test_#{test}" }
  end

  task :default => :all
end

# Documentation tasks
namespace :doc do
  # Default coverage threshold
  COVERAGE_THRESHOLD = ENV.fetch('COVERAGE_THRESHOLD', 80).to_i

  # Check RDoc coverage using rdoc -C
  desc "Check RDoc coverage using rdoc -C"
  task :check_coverage do
    rdoc_output = `rdoc -C lib`
    coverage_match = rdoc_output.match(/(\d+)% documented/)

    if coverage_match
      coverage = coverage_match[1].to_i
      puts "RDoc coverage: #{coverage}%"

      if coverage >= COVERAGE_THRESHOLD
        puts "RDoc coverage meets the threshold of #{COVERAGE_THRESHOLD}%."
      else
        puts "RDoc coverage is below the threshold of #{COVERAGE_THRESHOLD}%."
        exit 1
      end
    else
      puts "Could not determine RDoc coverage."
      puts rdoc_output
      exit 1
    end
  end
end

task :default => [:install, :all, "doc:check_coverage"]
