# frozen_string_literal: true

namespace :ui do
  desc 'Run End-to-End UI tests'
  task e2e: ['services:start'] do
    puts 'Running UI End-to-End Tests...'
    success = system('node scripts/verify_e2e_flow.js')

    # We don't automatically stop the server because it might have been running before
    # but for CI purposes, we want to know if it failed
    raise 'UI E2E Tests Failed!' unless success

    puts 'UI E2E Tests Passed!'
  end

  desc 'Build the UI assets'
  task :build do
    puts 'Building UI...'
    Dir.chdir('ui') do
      system('npm run build') || raise('UI Build Failed!')
    end
  end
end
