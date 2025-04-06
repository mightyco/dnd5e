require 'rake/testtask'
require "minitest/test_task"

task :install do
  sh "bundle install"
end

task :test => "test:default"

namespace :test do
  Minitest::TestTask.create(:all) do |t|
    t.libs << "test"
    t.libs << "lib"
    t.warning = false
    t.test_globs = ["test/**/test_*.rb"]
    t.verbose = false
  end

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

  task :default => "test:all"
end

task :default => [:install, :test]
