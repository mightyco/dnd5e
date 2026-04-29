# frozen_string_literal: true

require_relative '../../../test_helper'
require_relative '../../../../lib/dnd5e/core/features/druid_moon'

module Dnd5e
  module Core
    module Features
      class TestDruidMoon < Minitest::Test
        def test_primal_strike
          feature = PrimalStrike.new
          # Currently just executes the hook to ensure it doesn't crash
          # as it doesn't have much logic yet.
          feature.on_damage_calculation({ attacker: nil, defender: nil })

          assert_equal 'Primal Strike', feature.name
        end
      end
    end
  end
end
