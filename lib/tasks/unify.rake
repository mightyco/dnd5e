# frozen_string_literal: true

namespace :ui do
  desc 'Build the React application'
  task :build do
    puts 'Building React application...'
    sh 'npm run build --prefix ui'
  end

  desc 'Install UI dependencies'
  task :install do
    sh 'npm install --prefix ui'
  end
end

namespace :docs do
  desc 'Build the Docusaurus site'
  task :build do
    puts 'Building Docusaurus documentation...'
    sh 'npm run build --prefix docs/portal'
  end

  desc 'Install documentation dependencies'
  task :install do
    sh 'npm install --prefix docs/portal'
  end

  desc 'Reload documentation (rebuild MDX)'
  task :reload do
    puts 'Reloading documentation artifacts...'
    system('cd docs/portal && node scripts/build-docs.js')
    puts 'Documentation reloaded.'
  end

  desc 'Start Docusaurus dev server (Port 3000)'
  task :dev do
    puts 'Starting Docusaurus dev server...'
    sh 'npm start --prefix docs/portal'
  end
end

namespace :unify do
  desc 'Orchestrate UI and Docs builds'
  task build: %w[ui:build docs:build]
end
