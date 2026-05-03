# frozen_string_literal: true

require_relative 'test_helper'

# Load all tests for mutant
Dir.glob('test/**/*_test.rb').each { |f| require_relative "../#{f}" }
Dir.glob('test/**/test_*.rb').each { |f| require_relative "../#{f}" }
