# frozen_string_literal: true

require 'rake/testtask'

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

desc 'Run all examples to ensure they execute without error'
task :examples do
  puts 'Running examples...'
  Dir.glob('examples/*.rb').each do |file|
    puts "Running #{file}..."
    # Suppress stdout to keep the build output clean, unless it fails
    system("ruby -Ilib #{file} > /dev/null") || raise("Example #{file} failed!")
  end
  puts 'All examples passed.'
end

desc 'Run tests and linting'
task all: %i[test lint examples]

desc 'Run tests with coverage enabled'
task :coverage do
  ENV['COVERAGE'] = 'true'
  Rake::Task['test'].invoke
end
