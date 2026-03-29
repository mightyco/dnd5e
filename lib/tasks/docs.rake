# frozen_string_literal: true

namespace :services do
  namespace :docs do
    desc 'Start documentation portal'
    task(:start) { ServiceHelpers.start_docs }

    desc 'Stop documentation portal'
    task(:stop) { ServiceHelpers.stop_process(ServiceHelpers::DOCS_PID, 'Docs Portal') }

    desc 'Reload documentation (rebuild MDX)'
    task :reload do
      puts 'Reloading documentation artifacts...'
      system('cd docs/portal && node scripts/build-docs.js')
      puts 'Documentation reloaded.'
    end

    desc 'Show Docs portal status'
    task(:status) { ServiceHelpers.check_status(ServiceHelpers::DOCS_PID, 'Docs Portal') }
  end
end
