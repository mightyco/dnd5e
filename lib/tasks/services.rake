# frozen_string_literal: true

require 'fileutils'

# Helper methods for service management to keep Rake tasks lean
module ServiceHelpers
  PID_DIR = File.expand_path('../../tmp/pids', __dir__)
  API_PID = File.join(PID_DIR, 'sim_server.pid')
  DOCS_PID = File.join(PID_DIR, 'docusaurus.pid')

  def self.running?(pid_file)
    return false unless File.exist?(pid_file)

    pid = File.read(pid_file).to_i
    Process.kill(0, pid)
    true
  rescue Errno::ESRCH, Errno::ENOENT
    false
  end

  def self.read_pid(pid_file)
    File.read(pid_file).strip if File.exist?(pid_file)
  end

  def self.stop_process(pid_file, name)
    return puts "#{name} is not running." unless running?(pid_file)

    pid = read_pid(pid_file).to_i
    puts "Stopping #{name} (Group PID: #{pid})..."
    kill_process_group(pid)
    FileUtils.rm(pid_file)
    puts "#{name} stopped."
  end

  def self.kill_process_group(pid)
    Process.kill('-TERM', pid)
  rescue Errno::ESRCH
    Process.kill('TERM', pid)
  end

  def self.check_status(pid_file, name)
    if running?(pid_file)
      puts "#{name}: RUNNING (PID: #{read_pid(pid_file)})"
    else
      puts "#{name}: STOPPED"
    end
  end

  def self.start_api
    FileUtils.mkdir_p(PID_DIR)
    return puts "API Server is already running (PID: #{read_pid(API_PID)})" if running?(API_PID)

    puts 'Starting API Server...'
    pid = spawn('ruby scripts/sim_server.rb > log/api.log 2>&1', pgroup: true)
    File.write(API_PID, pid)
    puts "API Server started (PID: #{pid})"
  end

  def self.start_docs
    FileUtils.mkdir_p(PID_DIR)
    return puts "Docs Portal is already running (PID: #{read_pid(DOCS_PID)})" if running?(DOCS_PID)

    puts 'Starting Docs Portal...'
    system('cd docs/portal && node scripts/build-docs.js > /dev/null 2>&1')
    pid = spawn('cd docs/portal && npm run start > ../../log/docs.log 2>&1', pgroup: true)
    File.write(DOCS_PID, pid)
    puts "Docs Portal started (PID: #{pid})"
  end
end

namespace :services do
  desc 'Start all simulator services (API and Docs)'
  task start: %i[api:start docs:start]

  desc 'Stop all simulator services'
  task stop: %i[api:stop docs:stop]

  desc 'Restart all simulator services'
  task restart: %i[stop start]

  desc 'Show status of simulator services'
  task status: %i[api:status docs:status]
end
