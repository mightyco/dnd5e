# frozen_string_literal: true

require 'fileutils'

# Helper methods for service management to keep Rake tasks lean
module ServiceHelpers
  PID_DIR = File.expand_path('../../tmp/pids', __dir__)
  SERVER_PID = File.join(PID_DIR, 'sim_server.pid')

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

  def self.start_server
    FileUtils.mkdir_p(PID_DIR)
    return puts "Simulator Server is already running (PID: #{read_pid(SERVER_PID)})" if running?(SERVER_PID)

    puts 'Starting Unified Simulator Server...'
    pid = spawn('ruby scripts/sim_server.rb > log/api.log 2>&1', pgroup: true)
    File.write(SERVER_PID, pid)
    puts "Simulator Server started (PID: #{pid})"
    puts 'Access Simulation Lab: http://localhost:4567/'
    puts 'Access Documentation:  http://localhost:4567/docs'
  end
end

namespace :services do
  desc 'Start the unified simulator server'
  task start: :start_unified

  desc 'Stop the simulator server'
  task stop: :stop_unified

  desc 'Restart the simulator server'
  task restart: %i[stop start]

  desc 'Show server status'
  task status: :status_unified

  desc 'Internal: Start the unified server'
  task(:start_unified) { ServiceHelpers.start_server }

  desc 'Internal: Stop the unified server'
  task(:stop_unified) { ServiceHelpers.stop_process(ServiceHelpers::SERVER_PID, 'Simulator Server') }

  desc 'Internal: Show server status'
  task(:status_unified) { ServiceHelpers.check_status(ServiceHelpers::SERVER_PID, 'Simulator Server') }
end
