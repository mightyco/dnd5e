# frozen_string_literal: true

namespace :services do
  namespace :api do
    desc 'Start simulation API server'
    task(:start) { ServiceHelpers.start_api }

    desc 'Stop simulation API server'
    task(:stop) { ServiceHelpers.stop_process(ServiceHelpers::API_PID, 'API Server') }

    desc 'Show API server status'
    task(:status) { ServiceHelpers.check_status(ServiceHelpers::API_PID, 'API Server') }
  end
end
