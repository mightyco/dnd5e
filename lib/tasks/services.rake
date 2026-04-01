# frozen_string_literal: true

require 'fileutils'
require 'net/http'

# Helper methods for service management to keep Rake tasks lean
module ServiceHelpers
  PID_DIR = File.expand_path('../../tmp/pids', __dir__)
  SERVER_PID = File.join(PID_DIR, 'sim_server.pid')
  UI_INDEX = File.expand_path('../../ui/dist/index.html', __dir__)

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
    Process.kill('-TERM', -pid) # Kill process group
  rescue Errno::ESRCH
    Process.kill('TERM', pid)
  end

  def self.check_status(pid_file, name)
    if running?(pid_file)
      puts "#{name}: RUNNING (PID: #{read_pid(pid_file)})"
      verify_ui_accessibility if name == 'Simulator Server'
    else
      puts "#{name}: STOPPED"
    end
  end

  def self.verify_ui_accessibility
    uri = URI('http://localhost:4567/')
    response = Net::HTTP.get_response(uri)
    if response.content_type == 'text/html'
      puts '  UI Status: ACCESSIBLE (HTML)'
    else
      puts "  UI Status: \e[31mERROR\e[0m (Got #{response.content_type} instead of HTML)"
      puts '  Warning: Stale process detected. Run rake restart to fix.'
    end
  rescue StandardError => e
    puts "  UI Status: \e[31mUNREACHABLE\e[0m (#{e.message})"
  end

  def self.start_server
    validate_build_artifacts
    FileUtils.mkdir_p(PID_DIR)

    if running?(SERVER_PID)
      puts "Simulator Server is already running (PID: #{read_pid(SERVER_PID)})"
      return
    end

    puts 'Starting Unified Simulator Server...'
    pid = spawn('ruby scripts/sim_server.rb > log/api.log 2>&1', pgroup: true)
    File.write(SERVER_PID, pid)
    wait_for_startup
  end

  def self.validate_build_artifacts
    return if File.exist?(UI_INDEX)

    puts "\e[31mError: UI build artifacts missing!\e[0m"
    puts "Expected: #{UI_INDEX}"
    puts 'Run `bundle exec rake unify:build` first.'
    exit 1
  end

  def self.wait_for_startup
    puts 'Waiting for server to initialize...'
    10.times do
      sleep 1
      next unless server_responding_correctly?

      puts "Simulator Server started (PID: #{read_pid(SERVER_PID)})"
      puts 'Access Simulation Lab: http://localhost:4567/'
      return
    end
    puts "\e[31mWarning: Server started but UI is not yet accessible.\e[0m"
  end

  def self.server_responding_correctly?
    uri = URI('http://localhost:4567/')
    Net::HTTP.get_response(uri).content_type == 'text/html'
  rescue StandardError
    false
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
