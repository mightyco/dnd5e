# frozen_string_literal: true

namespace :quality do
  desc 'Run mutation testing on core namespaces'
  task mutate: :test do
    begin
      require 'mutant'
    rescue LoadError
      puts 'Mutant gem not found. Run bundle install first.'
      exit 1
    end

    # Define core targets
    targets = [
      'Dnd5e::Core::AttackResolver',
      'Dnd5e::Core::StatblockMechanics',
      'Dnd5e::Core::Dice'
    ]

    puts "Starting Mutation Testing for core modules: #{targets.join(', ')}..."

    # Execute mutant command
    args = [
      'run', '-I lib', '-I test', '-r ./test/all_tests',
      '--integration minitest', '--usage opensource',
      targets.join(' ')
    ]
    command = "MUTANT=true bundle exec mutant #{args.join(' ')}"

    system(command)
  end
end
