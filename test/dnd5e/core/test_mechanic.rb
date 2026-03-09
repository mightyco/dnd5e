# frozen_string_literal: true

require_relative '../../test_helper'
require_relative '../../../lib/dnd5e/core/mechanic'

module Dnd5e
  module Core
    class TestMechanic < Minitest::Test
      def test_initialization
        mechanic = Mechanic.new(
          name: 'Grappling',
          description: 'A special melee attack.'
        )

        assert_equal 'Grappling', mechanic.name
        assert_equal 'A special melee attack.', mechanic.description
      end
    end
  end
end
