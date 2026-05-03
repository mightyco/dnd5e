# frozen_string_literal: true

require_relative '../test_helper'
require_relative '../../lib/dnd5e/core/feature_manager'
require_relative '../../lib/dnd5e/core/feature'

class TestPerfHooks < Minitest::Test
  def test_hook_execution_overhead
    # Create 50 features with empty hooks
    features = 50.times.map { Dnd5e::Core::Feature.new(name: 'feat') }
    manager = Dnd5e::Core::FeatureManager.new(features)
    context = { a: 1 }

    start_time = Time.now
    10_000.times { manager.apply_modifier_hook(:on_attack_roll, context, 0) }
    duration = Time.now - start_time
    puts "\nHook execution (10,000x with 50 features): #{duration}s"
  end
end
