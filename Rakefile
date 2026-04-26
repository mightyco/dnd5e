# frozen_string_literal: true

require 'rake/testtask'
require 'etc'

# Load tasks from lib/tasks
Dir.glob('lib/tasks/*.rake').each { |r| import r }

# Default task to run tests, linting, and examples
task default: %i[test lint]

# Configure the test task
Rake::TestTask.new(:test) do |t|
  t.libs << 'test'
  t.libs << 'lib'
  t.test_files = FileList['test/**/*_test.rb', 'test/**/test_*.rb']
  t.verbose = true
  t.warning = false
end

# Define a lint task if RuboCop is available
begin
  require 'rubocop/rake_task'
  RuboCop::RakeTask.new(:lint) do |t|
    t.options = ['--display-cop-names']
  end
rescue LoadError
  task :lint do
    puts 'RuboCop is not available. Install it with `gem install rubocop`.'
  end
end

desc 'Run all examples in parallel'
task :examples do
  puts 'Running examples in parallel...'
  files = Dir.glob('examples/*.rb')

  # Fast development cycle: skip slow examples if FAST_SIM is set
  if ENV['FAST_SIM'] == 'true'
    slow_examples = %w[examples/example_science_initiative_impact.rb
                       examples/example_science_weapon_armor_progression.rb]
    puts "FAST_SIM enabled. Skipping slow examples: #{slow_examples.join(', ')}"
    files -= slow_examples
  end

  max_procs = Etc.nprocessors
  results = []

  files.each_slice((files.size.to_f / max_procs).ceil) do |slice|
    results << Thread.new do
      slice.each do |file|
        print '.'
        success = system("ruby -Ilib #{file} > /dev/null 2>&1")
        raise "Example #{file} failed!" unless success
      end
    end
  end

  results.each(&:join)
  puts "\nAll examples passed."
end

desc 'Run tests, linting, and e2e'
task all: %i[test lint ui:e2e examples]

desc 'Run tests with coverage enabled'
task :coverage do
  ENV['COVERAGE'] = 'true'
  Rake::Task['test'].invoke
end

desc 'Start all simulator services'
task start: 'services:start'

desc 'Stop all simulator services'
task stop: 'services:stop'

desc 'Restart all simulator services'
task restart: 'services:restart'

desc 'Show status of simulator services'
task status: 'services:status'
