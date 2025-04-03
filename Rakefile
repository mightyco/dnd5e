require 'rake/testtask'
require "minitest/test_task"

task :install do
  sh "bundle install"
end

task :test => :install


Minitest::TestTask.create(:test) do |t|
  t.libs << "test"
  t.libs << "lib"
  t.warning = false
  t.test_globs = ["test/**/test_*.rb"]
end

task :default => :test